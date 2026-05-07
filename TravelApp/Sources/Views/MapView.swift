import MapKit
import SwiftUI

struct MapView: View {
    @Bindable var viewModel: TripMapViewModel
    @State private var newSpotName: String = ""

    var body: some View {
        MapReader { proxy in
            Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedSpotID) {
                ForEach(viewModel.spots) { spot in
                    Annotation(spot.name, coordinate: spot.coordinate) {
                        SpotPin(spot: spot, isSelected: viewModel.selectedSpotID == spot.id)
                    }
                    .tag(spot.id)
                    .annotationTitles(.hidden)
                }

                if let coordinate = viewModel.creatingAt {
                    Annotation("New spot", coordinate: coordinate) {
                        Image(systemName: "mappin")
                            .font(.title)
                            .foregroundStyle(.tint)
                    }
                    .annotationTitles(.hidden)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .onTapGesture { location in
                guard let coordinate = proxy.convert(location, from: .local) else { return }
                viewModel.creatingAt = coordinate
                newSpotName = ""
            }
        }
        .overlay(alignment: .top) {
            if case .error(let message) = viewModel.loadState {
                ErrorBanner(message: message) {
                    Task { await viewModel.load() }
                }
                .padding()
            }
        }
        .overlay(alignment: .bottomTrailing) {
            MapLegend()
                .padding(12)
        }
        .onChange(of: viewModel.selectedSpotID) { _, newValue in
            guard let id = newValue,
                  let spot = viewModel.spots.first(where: { $0.id == id })
            else { return }
            viewModel.focus(on: spot)
        }
        .alert("New spot", isPresented: Binding(
            get: { viewModel.creatingAt != nil },
            set: { if !$0 { viewModel.creatingAt = nil } }
        )) {
            TextField("Name", text: $newSpotName)
            Button("Cancel", role: .cancel) {
                viewModel.creatingAt = nil
            }
            Button("Add") {
                if let coord = viewModel.creatingAt {
                    Task {
                        await viewModel.createSpot(at: coord, name: newSpotName)
                        viewModel.creatingAt = nil
                    }
                }
            }
        } message: {
            Text("Drop a pin and give it a name.")
        }
        .alert("Couldn't save", isPresented: Binding(
            get: { viewModel.saveError != nil },
            set: { if !$0 { viewModel.saveError = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.saveError = nil }
        } message: {
            Text(viewModel.saveError ?? "")
        }
    }
}

private struct SpotPin: View {
    let spot: Spot
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(.tint)
                .opacity(spot.inItinerary ? 1.0 : 0.55)
                .frame(width: isSelected ? 36 : 28, height: isSelected ? 36 : 28)
                .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                .shadow(radius: isSelected ? 4 : 1)
            Image(systemName: spot.category.symbolName)
                .font(.system(size: isSelected ? 16 : 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isSelected)
    }
}

private struct MapLegend: View {
    var body: some View {
        Label("Tap map to add a spot", systemImage: "hand.tap")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(8)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct ErrorBanner: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message).font(.caption)
            Spacer()
            Button("Retry", action: onRetry).font(.caption)
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .foregroundStyle(.red)
    }
}
