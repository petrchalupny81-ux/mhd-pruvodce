import SwiftUI

struct SkeletonRow: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 80, height: 20)
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 120, height: 14)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 60, height: 16)
        }
        .redacted(reason: .placeholder)
        .opacity(isAnimating ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear { isAnimating = true }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct LoadingSkeletonView: View {
    var count: Int = 3

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonRow()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    LoadingSkeletonView()
        .padding()
}
