import Foundation
import Supabase
import AuthenticationServices

struct AuthedUser: Sendable, Equatable {
    let id: UUID
    let email: String?
}

actor AuthRepo {
    static let shared = AuthRepo()

    private let client: SupabaseClient
    private init(client: SupabaseClient = SupabaseService.shared) {
        self.client = client
    }

    /// Stream of auth state changes — emits the current user (or nil) when it changes.
    /// `authStateChanges` emits an `initialSession` event on subscribe, so callers don't
    /// need a separate initial fetch.
    func userStream() -> AsyncStream<AuthedUser?> {
        AsyncStream { continuation in
            let task = Task {
                for await (_, session) in client.auth.authStateChanges {
                    let user = session.map { AuthedUser(id: $0.user.id, email: $0.user.email) }
                    continuation.yield(user)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    // MARK: - Sign in with Apple

    func signInWithApple(idToken: String, nonce: String) async throws -> AuthedUser {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        return AuthedUser(id: session.user.id, email: session.user.email)
    }

    // MARK: - Magic link

    func sendMagicLink(to email: String) async throws {
        try await client.auth.signInWithOTP(
            email: email,
            redirectTo: DeepLink.authCallback,
            shouldCreateUser: true
        )
    }

    /// Handle the URL the OS hands us when the user taps the magic link.
    func handleDeepLink(_ url: URL) async throws {
        try await client.auth.session(from: url)
    }
}
