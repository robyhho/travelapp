import Foundation

struct AppConfig {
    let supabaseURL: URL
    let supabaseAnonKey: String

    static let shared: AppConfig = {
        guard let info = Bundle.main.infoDictionary,
              let urlString = info["SUPABASE_URL"] as? String,
              let url = URL(string: urlString),
              let anon = info["SUPABASE_ANON_KEY"] as? String
        else {
            fatalError("Missing config keys in Info.plist — check Config.xcconfig")
        }
        return AppConfig(supabaseURL: url, supabaseAnonKey: anon)
    }()
}
