import Foundation
import MapKit
import SwiftUI

@Observable
@MainActor
final class TripMapViewModel {
    var spots: [MockSpot]
    var searchText: String = ""
    var selectedSpotID: MockSpot.ID?
    var cameraPosition: MapCameraPosition

    init(spots: [MockSpot] = MockData.spots) {
        self.spots = spots
        self.cameraPosition = .region(MockData.defaultRegion)
    }

    var filteredSpots: [MockSpot] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return spots }
        let needle = trimmed.lowercased()
        return spots.filter { spot in
            spot.name.lowercased().contains(needle)
                || spot.notes.lowercased().contains(needle)
                || spot.category.label.lowercased().contains(needle)
        }
    }

    var selectedSpot: MockSpot? {
        guard let id = selectedSpotID else { return nil }
        return spots.first { $0.id == id }
    }

    func select(_ spot: MockSpot) {
        selectedSpotID = spot.id
        focus(on: spot)
    }

    func focus(on spot: MockSpot) {
        let region = MKCoordinateRegion(
            center: spot.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        )
        withAnimation(.easeInOut(duration: 0.35)) {
            cameraPosition = .region(region)
        }
    }

    func clearSelection() {
        selectedSpotID = nil
    }
}
