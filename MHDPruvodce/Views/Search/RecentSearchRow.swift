import SwiftUI
import SwiftData

struct RecentSearchRow: View {
    let savedSearch: SavedSearch
    let onTap: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: savedSearch.isFavorite ? "star.fill" : "clock")
                        .foregroundStyle(savedSearch.isFavorite ? .yellow : .secondary)
                        .font(.caption)
                    Text(savedSearch.displayTitle)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                Text(savedSearch.timestamp.mhdDateString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .topTrailing) {
                Button(action: onToggleFavorite) {
                    Image(systemName: savedSearch.isFavorite ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundStyle(savedSearch.isFavorite ? .yellow : .secondary)
                        .padding(8)
                }
                .hapticTap(style: .light)
            }
        }
        .hapticTap(style: .light)
    }
}
