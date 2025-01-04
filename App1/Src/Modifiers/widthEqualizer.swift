
import SwiftUI



/// Inspired by
/// https://gist.github.com/nRewik/f510df64a72257cffd01294ee7107dfd



struct LargestWidthPreferenceKey: PreferenceKey {
    
    
    static var defaultValue: CGFloat = 0.0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
    
}



struct EqualWidths: ViewModifier {
    
    
    @Binding var width: CGFloat?
    
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(LargestWidthPreferenceKey.self) { value in
                width = value
            }
    }
}



extension View {
    
    
    @ViewBuilder func equalWidths() -> some View {
    
        self.background(GeometryReader { geo in
            Color.clear.preference(
                key: LargestWidthPreferenceKey.self,
                value: geo.frame(in: .global).size.width
            )
        })
    }
    
    
    @ViewBuilder func equalWidths(_ width: Binding<CGFloat?>) -> some View {
    
        self.modifier(EqualWidths(width: width))
    }
}
