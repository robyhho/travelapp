import SwiftUI

struct TripScreen: View {
    @State private var viewModel: TripMapViewModel

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    init(trip: Trip, currentUserId: UUID) {
        _viewModel = State(initialValue: TripMapViewModel(trip: trip, currentUserId: currentUserId))
    }

    var body: some View {
        layout
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var layout: some View {
        #if os(iOS)
        if sizeClass == .compact {
            CompactTripLayout(viewModel: viewModel)
        } else {
            RegularTripLayout(viewModel: viewModel)
        }
        #else
        RegularTripLayout(viewModel: viewModel)
        #endif
    }
}

private struct RegularTripLayout: View {
    @Bindable var viewModel: TripMapViewModel

    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel)
                .navigationSplitViewColumnWidth(min: 280, ideal: 340, max: 420)
        } detail: {
            MapView(viewModel: viewModel)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

#if os(iOS)
private struct CompactTripLayout: View {
    @Bindable var viewModel: TripMapViewModel
    @State private var sheetDetent: PresentationDetent = .fraction(0.4)

    var body: some View {
        MapView(viewModel: viewModel)
            .ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                SidebarView(viewModel: viewModel)
                    .presentationDetents(
                        [.height(120), .fraction(0.4), .large],
                        selection: $sheetDetent
                    )
                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.4)))
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
            }
            .onChange(of: viewModel.selectedSpotID) { _, newValue in
                if newValue != nil, sheetDetent == .height(120) {
                    sheetDetent = .fraction(0.4)
                }
            }
    }
}
#endif
