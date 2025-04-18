
import SwiftUI



struct PreviewShippingStore: ShippingStoreProtocol {


    func confirmedShippingCost(for order: Order) -> Float? {
        
        return nil
    }
    
    func confirmShippingCost(for order: Order, cost: Float) {
        
    }
    
    func selectedShippingCost(for order: Order) -> SelectedShippingCost? {
        
        return nil
    }
    
    func confirmedStamping(for order: Order) -> String? {
        
        return nil
    }
    
    func confirmStamping(for order: Order, stamping: String) {
        
    }
    
    func dateOrderValidatedWithoutStamping(_ order: Order) -> Date? {
        
        return nil
    }
    
    func validateOrderWithoutStamping(_ order: Order) {
        
    }
    
    func recommendedStampingMethod(for order: Order) -> String {

        return ""
    }
}
