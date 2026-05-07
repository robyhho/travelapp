import Foundation
import MapKit

enum MockData {
    static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737),
        span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    )

    static let spots: [MockSpot] = [
        MockSpot(
            id: UUID(uuidString: "11111111-0000-0000-0000-000000000001")!,
            name: "The Bund",
            latitude: 31.2397,
            longitude: 121.4900,
            category: .sight,
            notes: "Riverside promenade with colonial-era buildings. Best at dusk.",
            authorColor: .teal,
            inItinerary: true
        ),
        MockSpot(
            id: UUID(uuidString: "11111111-0000-0000-0000-000000000002")!,
            name: "Yu Garden",
            latitude: 31.2272,
            longitude: 121.4920,
            category: .sight,
            notes: "Classical Ming-dynasty garden, very crowded by 11am.",
            authorColor: .orange,
            inItinerary: true
        ),
        MockSpot(
            id: UUID(uuidString: "11111111-0000-0000-0000-000000000003")!,
            name: "Din Tai Fung (Xintiandi)",
            latitude: 31.2207,
            longitude: 121.4756,
            category: .food,
            notes: "Xiao long bao. Reserve via WeChat or queue 30+ min.",
            authorColor: .teal,
            inItinerary: true
        ),
        MockSpot(
            id: UUID(uuidString: "11111111-0000-0000-0000-000000000004")!,
            name: "Jing'an Temple",
            latitude: 31.2236,
            longitude: 121.4453,
            category: .sight,
            notes: "Gold-roofed temple sitting in the middle of the financial district.",
            authorColor: .orange,
            inItinerary: false
        ),
        MockSpot(
            id: UUID(uuidString: "11111111-0000-0000-0000-000000000005")!,
            name: "Tianzifang",
            latitude: 31.2106,
            longitude: 121.4655,
            category: .shopping,
            notes: "Maze of arts-and-crafts lanes in the French Concession.",
            authorColor: .teal,
            inItinerary: false
        ),
        MockSpot(
            id: UUID(uuidString: "11111111-0000-0000-0000-000000000006")!,
            name: "Pudong Shangri-La",
            latitude: 31.2385,
            longitude: 121.4998,
            category: .hotel,
            notes: "River-view rooms; check in after 3pm.",
            authorColor: .orange,
            inItinerary: true
        ),
        MockSpot(
            id: UUID(uuidString: "11111111-0000-0000-0000-000000000007")!,
            name: "Shanghai Hongqiao Station",
            latitude: 31.1944,
            longitude: 121.3211,
            category: .transit,
            notes: "High-speed rail to Hangzhou, Suzhou, Beijing.",
            authorColor: .teal,
            inItinerary: true
        ),
        MockSpot(
            id: UUID(uuidString: "11111111-0000-0000-0000-000000000008")!,
            name: "Century Park",
            latitude: 31.2210,
            longitude: 121.5510,
            category: .nature,
            notes: "Largest park in Pudong, rent a tandem bike.",
            authorColor: .orange,
            inItinerary: false
        )
    ]
}
