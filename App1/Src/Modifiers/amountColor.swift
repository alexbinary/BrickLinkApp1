
import SwiftUI



extension View {
    
    
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
    
    
    @ViewBuilder func amountColor(_ mode: ColorationMode) -> some View {
    
        switch mode {
            
        case .goodIfPositive(let amount, let meaningOfZero):
            
            self.amountColor(amount == 0 ? meaningOfZero : (amount > 0 ? .good : .bad))
            
        case .badIfPositive(let amount, let meaningOfZero):
            
            self.amountColor(amount == 0 ? meaningOfZero : (amount > 0 ? .bad : .good))
            
        case .goodIf(let condition):
            
            self.amountColor(condition ? .good : .bad)
            
        case .badIf(let condition):
            
            self.amountColor(condition ? .bad : .good)
        }
    }
}


enum ColorationMode {
    
    case goodIfPositive(Float, zero: ColorMeaning)
    case badIfPositive(Float, zero: ColorMeaning)
    case goodIf(Bool)
    case badIf(Bool)
}


enum ColorMeaning {
    
    case good
    case bad
    case neutral
}
