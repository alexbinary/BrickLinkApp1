
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
                backgroundColor: .quaternarySystemFill,
                borderColor: .tertiarySystemFill
            )
            
        case .secondary:
            
            self.roundedContainer(
                backgroundColor: .windowBackgroundColor,
                borderColor: .secondarySystemFill
            )
            
        case .outline:
            
            self.roundedContainer(
                backgroundColor: .clear,
                borderColor: .tertiarySystemFill
            )
            
        case .info:
            
            self.roundedContainer(
                backgroundColor: .secondarySystemFill.opacity(0.7),
                borderColor: .tertiarySystemFill
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
