import Foundation

struct Trip: Identifiable, Hashable, Sendable, Codable {
    let id: UUID
    var name: String
    var ownerId: UUID
    var startDate: Date?
    var endDate: Date?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case ownerId   = "owner_id"
        case startDate = "start_date"
        case endDate   = "end_date"
        case createdAt = "created_at"
    }
}

struct NewTrip: Encodable, Sendable {
    var name: String
    var ownerId: UUID
    var startDate: Date?
    var endDate: Date?

    enum CodingKeys: String, CodingKey {
        case name
        case ownerId   = "owner_id"
        case startDate = "start_date"
        case endDate   = "end_date"
    }
}
