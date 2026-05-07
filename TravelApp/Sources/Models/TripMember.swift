import Foundation

struct TripMember: Identifiable, Hashable, Sendable, Codable {
    var tripId: UUID
    var userId: UUID
    var displayName: String
    var colour: String  // hex string, e.g. "#14b8a6"
    var role: Role
    var status: Status
    var joinedAt: Date

    var id: String { "\(tripId.uuidString):\(userId.uuidString)" }

    enum Role: String, Codable, Sendable, Hashable { case owner, member }
    enum Status: String, Codable, Sendable, Hashable { case active, pending }

    enum CodingKeys: String, CodingKey {
        case tripId      = "trip_id"
        case userId      = "user_id"
        case displayName = "display_name"
        case colour
        case role
        case status
        case joinedAt    = "joined_at"
    }
}
