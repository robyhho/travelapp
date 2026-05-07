import CoreLocation
import Foundation

struct Spot: Identifiable, Hashable, Sendable, Codable {
    let id: UUID
    var tripId: UUID
    var createdBy: UUID
    var name: String
    var lat: Double
    var lng: Double
    var category: SpotCategory
    var notes: String
    var websiteUrl: String?
    var inItinerary: Bool
    var dayId: UUID?
    var orderInDay: Int?
    var createdAt: Date
    var updatedAt: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case tripId       = "trip_id"
        case createdBy    = "created_by"
        case name
        case lat
        case lng
        case category
        case notes
        case websiteUrl   = "website_url"
        case inItinerary  = "in_itinerary"
        case dayId        = "day_id"
        case orderInDay   = "order_in_day"
        case createdAt    = "created_at"
        case updatedAt    = "updated_at"
    }
}

struct NewSpot: Encodable, Sendable {
    var tripId: UUID
    var createdBy: UUID
    var name: String
    var lat: Double
    var lng: Double
    var category: SpotCategory
    var notes: String
    var inItinerary: Bool

    enum CodingKeys: String, CodingKey {
        case tripId      = "trip_id"
        case createdBy   = "created_by"
        case name
        case lat
        case lng
        case category
        case notes
        case inItinerary = "in_itinerary"
    }
}
