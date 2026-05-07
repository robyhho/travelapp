import Foundation
import SwiftUI

@Observable
@MainActor
final class AppSession {
    enum Phase: Equatable {
        case loading
        case signedOut
        case signedIn(AuthedUser)
    }

    var phase: Phase = .loading
    private var watchTask: Task<Void, Never>?

    func start() {
        watchTask?.cancel()
        watchTask = Task { [weak self] in
            for await user in await AuthRepo.shared.userStream() {
                guard let self else { return }
                self.phase = user.map(Phase.signedIn) ?? .signedOut
            }
        }
    }

    func signOut() async {
        try? await AuthRepo.shared.signOut()
    }
}
