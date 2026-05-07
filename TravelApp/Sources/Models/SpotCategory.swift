import SwiftUI

enum SpotCategory: String, CaseIterable, Identifiable, Hashable, Sendable {
    case food
    case sight
    case hotel
    case transit
    case shopping
    case nature
    case other

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .food: "fork.knife"
        case .sight: "camera"
        case .hotel: "bed.double.fill"
        case .transit: "tram.fill"
        case .shopping: "bag.fill"
        case .nature: "leaf.fill"
        case .other: "mappin"
        }
    }

    var label: String {
        switch self {
        case .food: "Food"
        case .sight: "Sight"
        case .hotel: "Hotel"
        case .transit: "Transit"
        case .shopping: "Shopping"
        case .nature: "Nature"
        case .other: "Other"
        }
    }
}
