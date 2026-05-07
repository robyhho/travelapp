import SwiftUI

struct SpotRow: View {
    let spot: MockSpot
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(spot.authorColor.color)
                    .opacity(spot.inItinerary ? 1.0 : 0.55)
                    .frame(width: 32, height: 32)
                Image(systemName: spot.category.symbolName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(spot.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(spot.category.label + (spot.inItinerary ? "" : " · Wishlist"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .listRowBackground(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
    }
}
