
import SwiftUI



extension View {
    
    
    @ViewBuilder func roundedContainer(
        
        backgroundColor: Color,
        borderColor: Color,
        lineWidth: CGFloat = 1,
        cornerRadius: CGFloat = 6
        
    ) -> some View {
        
        self
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: lineWidth)
            )
    }
    
    
    @ViewBuilder func roundedContainer(style: RoundedBackgroundStyle) -> some View {
        
        switch style {
            
        case .primary:
            
            self.roundedContainer(
                backgroundColor: Color(nsColor: .quaternarySystemFill),
                borderColor: Color(nsColor: .tertiarySystemFill)
            )
            
        case .secondary:
            
            self.roundedContainer(
                backgroundColor: Color(nsColor: .windowBackgroundColor),
                borderColor: Color(nsColor: .secondarySystemFill)
            )
            
        case .outline:
            
            self.roundedContainer(
                backgroundColor: .clear,
                borderColor: Color(nsColor: .tertiarySystemFill)
            )
            
        case .info:
            
            self.roundedContainer(
                backgroundColor: Color(nsColor: .secondarySystemFill).opacity(0.7),
                borderColor: Color(nsColor: .tertiarySystemFill)
            )
            
        case .tag(let color):
            
            self.roundedContainer(
                backgroundColor: color.opacity(0.1),
                borderColor: color.opacity(0.7),
                lineWidth: 0.5,
                cornerRadius: 3
            )
        }
    }
}



enum RoundedBackgroundStyle {
    
    case primary
    case secondary
    case outline
    case info
    case tag(baseColor: Color)
}
