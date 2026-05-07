import CoreLocation
import SwiftUI

struct MockSpot: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var category: SpotCategory
    var notes: String
    var authorColor: AuthorColor
    var inItinerary: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum AuthorColor: String, CaseIterable, Hashable, Sendable {
    case teal
    case orange

    var color: Color {
        switch self {
        case .teal: .teal
        case .orange: .orange
        }
    }

    var displayName: String {
        switch self {
        case .teal: "Robbie"
        case .orange: "Companion"
        }
    }
}
