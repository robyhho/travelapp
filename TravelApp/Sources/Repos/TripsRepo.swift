import Foundation
import Supabase

actor TripsRepo {
    static let shared = TripsRepo()

    private let client: SupabaseClient
    private init(client: SupabaseClient = SupabaseService.shared) {
        self.client = client
    }

    func list() async throws -> [Trip] {
        try await client
            .from("trips")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func get(id: UUID) async throws -> Trip {
        try await client
            .from("trips")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    func create(name: String, ownerId: UUID, startDate: Date? = nil, endDate: Date? = nil) async throws -> Trip {
        let payload = NewTrip(name: name, ownerId: ownerId, startDate: startDate, endDate: endDate)
        return try await client
            .from("trips")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }
}
