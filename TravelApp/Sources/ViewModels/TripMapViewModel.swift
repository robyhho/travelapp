import Foundation
import MapKit
import SwiftUI

@Observable
@MainActor
final class TripMapViewModel {
    let trip: Trip
    let currentUserId: UUID

    var spots: [Spot] = []
    var loadState: LoadState = .loading
    var searchText: String = ""
    var selectedSpotID: Spot.ID?
    var cameraPosition: MapCameraPosition

    var creatingAt: CLLocationCoordinate2D?
    var saveError: String?

    init(trip: Trip, currentUserId: UUID) {
        self.trip = trip
        self.currentUserId = currentUserId
        self.cameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737), // Shanghai placeholder
                span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
            )
        )
    }

    var partitionedSpots: (itinerary: [Spot], wishlist: [Spot]) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let needle = trimmed.isEmpty ? nil : trimmed.lowercased()
        var itinerary: [Spot] = []
        var wishlist: [Spot] = []
        for spot in spots {
            if let needle,
               !spot.name.lowercased().contains(needle),
               !spot.notes.lowercased().contains(needle),
               !spot.category.label.lowercased().contains(needle) {
                continue
            }
            if spot.inItinerary { itinerary.append(spot) } else { wishlist.append(spot) }
        }
        return (itinerary, wishlist)
    }

    var selectedSpot: Spot? {
        guard let id = selectedSpotID else { return nil }
        return spots.first { $0.id == id }
    }

    func load() async {
        loadState = .loading
        do {
            spots = try await SpotsRepo.shared.list(tripId: trip.id)
            loadState = .loaded
            if let first = spots.first {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: first.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )
                )
            }
        } catch {
            loadState = .error(error.localizedDescription)
        }
    }

    func select(_ spot: Spot) {
        selectedSpotID = spot.id
        focus(on: spot)
    }

    func focus(on spot: Spot) {
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

    func createSpot(at coordinate: CLLocationCoordinate2D, name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        do {
            let spot = try await SpotsRepo.shared.create(
                tripId: trip.id,
                createdBy: currentUserId,
                name: trimmed,
                lat: coordinate.latitude,
                lng: coordinate.longitude
            )
            spots.append(spot)
            selectedSpotID = spot.id
        } catch {
            saveError = error.localizedDescription
        }
    }

    func deleteSpot(_ spot: Spot) async {
        do {
            try await SpotsRepo.shared.delete(id: spot.id)
            spots.removeAll { $0.id == spot.id }
            if selectedSpotID == spot.id { selectedSpotID = nil }
        } catch {
            saveError = error.localizedDescription
        }
    }
}
