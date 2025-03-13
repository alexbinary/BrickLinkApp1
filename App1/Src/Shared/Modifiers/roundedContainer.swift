
import SwiftUI



extension View {
    
    
    @ViewBuilder func roundedContainer(
        
        fill backgroundColor: Color,
        stroke borderColor: Color,
        lineWidth: CGFloat = 1,
        cornerRadius: CGFloat = 6
        
    ) -> some View {
        
        self.background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(borderColor, lineWidth: lineWidth))
    }
    
    
    @ViewBuilder func roundedContainer(style: RoundedBackgroundStyle) -> some View {
        
        switch style {
            
        case .primary:
            self.roundedContainer(fill: .quaternarySystemFill, stroke: .tertiarySystemFill)
            
        case .secondary:
            self.roundedContainer(fill: .windowBackgroundColor, stroke: .secondarySystemFill)
            
        case .outline:
            self.roundedContainer(fill: .clear, stroke: .tertiarySystemFill)
            
        case .info:
            self.roundedContainer(fill: .secondarySystemFill.opacity(0.7), stroke: .tertiarySystemFill)
            
        case .tag(let color):
            self.roundedContainer(fill: color.opacity(0.1), stroke: color.opacity(0.7),
                                  lineWidth: 0.5, cornerRadius: 3
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
