import SwiftUI

struct RootView: View {
    @State private var session = AppSession()

    var body: some View {
        Group {
            switch session.phase {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .signedOut:
                AuthView()
            case .signedIn(let user):
                TripsListView(user: user)
            }
        }
        .environment(session)
        .task { session.start() }
        .onOpenURL { url in
            Task { try? await AuthRepo.shared.handleDeepLink(url) }
        }
    }
}
