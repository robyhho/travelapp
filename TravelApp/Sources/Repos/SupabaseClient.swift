import Foundation
import Supabase

enum SupabaseService {
    static let shared: SupabaseClient = {
        let cfg = AppConfig.shared
        return SupabaseClient(
            supabaseURL: cfg.supabaseURL,
            supabaseKey: cfg.supabaseAnonKey
        )
    }()
}
