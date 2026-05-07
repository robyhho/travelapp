import Foundation
import Supabase

actor SpotsRepo {
    static let shared = SpotsRepo()

    private let client: SupabaseClient
    private init(client: SupabaseClient = SupabaseService.shared) {
        self.client = client
    }

    func list(tripId: UUID) async throws -> [Spot] {
        try await client
            .from("spots")
            .select()
            .eq("trip_id", value: tripId)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    func create(
        tripId: UUID,
        createdBy: UUID,
        name: String,
        lat: Double,
        lng: Double,
        category: SpotCategory = .other,
        notes: String = "",
        inItinerary: Bool = false
    ) async throws -> Spot {
        let payload = NewSpot(
            tripId: tripId,
            createdBy: createdBy,
            name: name,
            lat: lat,
            lng: lng,
            category: category,
            notes: notes,
            inItinerary: inItinerary
        )
        return try await client
            .from("spots")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }

    func delete(id: UUID) async throws {
        try await client
            .from("spots")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
