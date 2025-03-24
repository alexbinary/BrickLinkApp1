
import Foundation



@Observable
class ShippingUserStore {
    
    
    private let shippingStore: ShippingStore
    
    
    init(_ shippingStore: ShippingStore) {
        self.shippingStore = shippingStore
    }
    
    
    // MARK: - Shipping cost
    
    
    public func confirmedShippingCost(forOrderWithId orderId: OrderSummary.ID) -> Float? {
        
        shippingStore.confirmedShippingCost(forOrderWithId: orderId)
    }
    
    
    public func confirmShippingCost(forOrderWithId orderId: OrderSummary.ID, cost: Float) {
        
        shippingStore.confirmShippingCost(forOrderWithId: orderId, cost: cost)
    }
    
    
    public func selectedShippingCost(forOrderWithId orderId: OrderSummary.ID) -> SelectedShippingCost? {
        
        shippingStore.selectedShippingCost(forOrderWithId: orderId)
    }
    
    
    // MARK: - Stamping
    
    
    public func confirmedStamping(forOrderWithId orderId: OrderSummary.ID) -> String? {
        
        shippingStore.confirmedStamping(forOrderWithId: orderId)
    }
    
    
    public func confirmStamping(forOrderWithId orderId: OrderSummary.ID, stamping: String) {
        
        shippingStore.confirmStamping(forOrderWithId: orderId, stamping: stamping)
    }
    
    
    public func dateOrderValidatedWithoutStamping(orderId: OrderDetails.ID) -> Date? {
        
        shippingStore.dateOrderValidatedWithoutStamping(orderId: orderId)
    }
    
    
    public func validateOrderWithoutStamping(orderId: OrderDetails.ID) {
        
        shippingStore.validateOrderWithoutStamping(orderId: orderId)
    }
    
    
    public func recommendedStampingMethod(forOrderWithId orderId: OrderSummary.ID) -> String {
        
        shippingStore.recommendedStampingMethod(forOrderWithId: orderId)
    }
}
