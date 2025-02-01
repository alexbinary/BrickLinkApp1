
import SwiftUI



extension View {
    
    
    @ViewBuilder func amountColor(_ amount: Float) -> some View {
        
        self.amountColor(amount > 0 ? .income : .expense)
    }
    
    @ViewBuilder func amountColor(_ type: AmountType) -> some View {
    
        self.foregroundColor(type == .income ? green : red)
    }
}


enum AmountType {
    
    case income
    case expense
}
