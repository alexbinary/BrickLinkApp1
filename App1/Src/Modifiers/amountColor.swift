
import SwiftUI



extension View {
    
    
    @ViewBuilder func amountColor(_ amount: Float) -> some View {
        
        self.amountColor(amount > 0 ? .good : .bad)
    }
    
    
    @ViewBuilder func amountColor(_ meaning: ColorMeaning) -> some View {
    
        switch meaning {
            
        case .good:
            self.foregroundColor(green)
            
        case .bad:
            self.foregroundColor(red)
            
        case .neutral:
            self
        }
    }
}


enum ColorMeaning {
    
    case good
    case bad
    case neutral
}
