import Foundation

enum LoadState: Equatable {
    case loading
    case loaded
    case error(String)
}

enum DeepLink {
    static let scheme = "travelapp"
    static let authCallback = URL(string: "\(scheme)://auth-callback")!
}
