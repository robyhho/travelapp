import MapKit
import SwiftUI

struct MapView: View {
    @Bindable var viewModel: TripMapViewModel

    var body: some View {
        Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedSpotID) {
            ForEach(viewModel.spots) { spot in
                Annotation(spot.name, coordinate: spot.coordinate) {
                    SpotPin(spot: spot, isSelected: viewModel.selectedSpotID == spot.id)
                }
                .tag(spot.id)
                .annotationTitles(.hidden)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
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
    }
}

private struct SpotPin: View {
    let spot: MockSpot
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(spot.authorColor.color)
                .opacity(spot.inItinerary ? 1.0 : 0.55)
                .frame(width: isSelected ? 36 : 28, height: isSelected ? 36 : 28)
                .overlay(
                    Circle()
                        .strokeBorder(.white, lineWidth: 2)
                )
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
        VStack(alignment: .leading, spacing: 4) {
            ForEach(AuthorColor.allCases, id: \.self) { author in
                HStack(spacing: 6) {
                    Circle()
                        .fill(author.color)
                        .frame(width: 10, height: 10)
                    Text(author.displayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
