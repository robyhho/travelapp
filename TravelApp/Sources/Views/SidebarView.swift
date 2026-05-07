import SwiftUI

struct SidebarView: View {
    @Bindable var viewModel: TripMapViewModel

    var body: some View {
        VStack(spacing: 0) {
            header

            if let selected = viewModel.selectedSpot {
                SpotDetailView(spot: selected) {
                    viewModel.clearSelection()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                spotList
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedSpotID)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shanghai trip")
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
        let spots = viewModel.filteredSpots
        if spots.isEmpty {
            ContentUnavailableView(
                viewModel.searchText.isEmpty ? "No spots yet" : "No matches",
                systemImage: viewModel.searchText.isEmpty ? "mappin.slash" : "magnifyingglass",
                description: Text(viewModel.searchText.isEmpty
                                  ? "Pinned spots will show up here."
                                  : "Try a different search.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(selection: $viewModel.selectedSpotID) {
                Section("Itinerary") {
                    ForEach(spots.filter(\.inItinerary)) { spot in
                        SpotRow(spot: spot, isSelected: viewModel.selectedSpotID == spot.id)
                            .tag(Optional(spot.id))
                    }
                }
                let wishlist = spots.filter { !$0.inItinerary }
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
