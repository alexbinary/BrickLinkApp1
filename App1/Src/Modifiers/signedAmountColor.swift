
import SwiftUI



extension View {
    
    
    @ViewBuilder func signedAmountColor(_ amount: Float) -> some View {
        
        self.signedAmountColor(amount > 0 ? .income : .expense)
    }
    
    @ViewBuilder func signedAmountColor(_ type: AmountType) -> some View {
    
        self.foregroundColor(type == .income ? green : red)
    }
}


enum AmountType {
    
    case income
    case expense
}
