import SwiftUI

struct TripsListView: View {
    let user: AuthedUser

    @Environment(AppSession.self) private var session
    @State private var trips: [Trip] = []
    @State private var loadState: LoadState = .loading
    @State private var showCreateSheet = false
    @State private var selectedTrip: Trip?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Trips")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showCreateSheet = true
                        } label: {
                            Label("New trip", systemImage: "plus")
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Menu {
                            if let email = user.email {
                                Text(email)
                            }
                            Button("Sign out", role: .destructive) {
                                Task { await session.signOut() }
                            }
                        } label: {
                            Image(systemName: "person.crop.circle")
                        }
                    }
                }
                .navigationDestination(item: $selectedTrip) { trip in
                    TripScreen(trip: trip, currentUserId: user.id)
                }
                .sheet(isPresented: $showCreateSheet) {
                    CreateTripSheet(ownerId: user.id) { trip in
                        trips.insert(trip, at: 0)
                        selectedTrip = trip
                    }
                }
                .task { await load(initial: true) }
                .refreshable { await load(initial: false) }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch loadState {
        case .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .error(let message):
            ContentUnavailableView {
                Label("Couldn't load trips", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Retry") { Task { await load(initial: true) } }
            }
        case .loaded:
            if trips.isEmpty {
                ContentUnavailableView {
                    Label("No trips yet", systemImage: "map")
                } description: {
                    Text("Tap + to start planning your first trip.")
                }
            } else {
                List(trips) { trip in
                    Button { selectedTrip = trip } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trip.name).font(.headline)
                            if let start = trip.startDate, let end = trip.endDate {
                                Text("\(start.formatted(date: .abbreviated, time: .omitted)) – \(end.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func load(initial: Bool) async {
        if initial { loadState = .loading }
        do {
            trips = try await TripsRepo.shared.list()
            loadState = .loaded
        } catch {
            loadState = .error(error.localizedDescription)
        }
    }
}

private struct CreateTripSheet: View {
    let ownerId: UUID
    var onCreated: (Trip) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 6, to: .now) ?? .now
    @State private var includeDates = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip") {
                    TextField("Name", text: $name)
                    Toggle("Set dates", isOn: $includeDates)
                    if includeDates {
                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                        DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red) }
                }
            }
            .navigationTitle("New trip")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { Task { await create() } }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
        }
    }

    private func create() async {
        isSaving = true
        defer { isSaving = false }
        do {
            let trip = try await TripsRepo.shared.create(
                name: name.trimmingCharacters(in: .whitespaces),
                ownerId: ownerId,
                startDate: includeDates ? startDate : nil,
                endDate: includeDates ? endDate : nil
            )
            onCreated(trip)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
