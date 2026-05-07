import SwiftUI

struct SidebarView: View {
    @Bindable var viewModel: TripMapViewModel

    var body: some View {
        VStack(spacing: 0) {
            header

            switch viewModel.loadState {
            case .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let message):
                ContentUnavailableView {
                    Label("Couldn't load spots", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry") { Task { await viewModel.load() } }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded:
                if let selected = viewModel.selectedSpot {
                    SpotDetailView(spot: selected,
                                   onClose: { viewModel.clearSelection() },
                                   onDelete: { Task { await viewModel.deleteSpot(selected) } })
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    spotList
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedSpotID)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.trip.name)
                .font(.title2.weight(.semibold))
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search spots", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var spotList: some View {
        let (itinerary, wishlist) = viewModel.partitionedSpots
        if itinerary.isEmpty && wishlist.isEmpty {
            ContentUnavailableView(
                viewModel.searchText.isEmpty ? "No spots yet" : "No matches",
                systemImage: viewModel.searchText.isEmpty ? "mappin.slash" : "magnifyingglass",
                description: Text(viewModel.searchText.isEmpty
                                  ? "Tap on the map to drop your first pin."
                                  : "Try a different search.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(selection: $viewModel.selectedSpotID) {
                if !itinerary.isEmpty {
                    Section("Itinerary") {
                        ForEach(itinerary) { spot in
                            SpotRow(spot: spot, isSelected: viewModel.selectedSpotID == spot.id)
                                .tag(Optional(spot.id))
                        }
                    }
                }
                if !wishlist.isEmpty {
                    Section("Wishlist") {
                        ForEach(wishlist) { spot in
                            SpotRow(spot: spot, isSelected: viewModel.selectedSpotID == spot.id)
                                .tag(Optional(spot.id))
                        }
                    }
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.sidebar)
            #endif
        }
    }
}
