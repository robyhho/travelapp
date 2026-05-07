import SwiftUI

struct SpotDetailView: View {
    let spot: Spot
    var onClose: () -> Void
    var onDelete: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.tint)
                            .opacity(spot.inItinerary ? 1.0 : 0.55)
                            .frame(width: 44, height: 44)
                        Image(systemName: spot.category.symbolName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(spot.name)
                            .font(.title3.weight(.semibold))
                        Text(spot.category.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }

                if !spot.notes.isEmpty {
                    Text(spot.notes)
                        .font(.body)
                        .foregroundStyle(.primary)
                }

                Label(spot.inItinerary ? "In itinerary" : "On wishlist",
                      systemImage: spot.inItinerary ? "checkmark.circle.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label(String(format: "%.4f, %.4f", spot.lat, spot.lng),
                      systemImage: "location")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)

                Button(role: .destructive, action: onDelete) {
                    Label("Delete spot", systemImage: "trash")
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}
