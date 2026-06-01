import SwiftUI

extension View {
    func hapticTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                UIImpactFeedbackGenerator(style: style).impactOccurred()
            }
        )
    }
}
