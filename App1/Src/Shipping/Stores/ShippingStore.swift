
import Foundation



class ShippingStore {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    
    // MARK: - Shipping cost
    
    
    public func confirmedShippingCost(forOrderWithId orderId: OrderSummary.ID) -> Float? {
        
        return dataStore.shippingCostsByOrderId[orderId]
    }
    
    
    public func confirmShippingCost(forOrderWithId orderId: OrderSummary.ID, cost: Float) {
        
        try! dataStore.setShippingCost(cost, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    // MARK: - Stamping
    
    
    public func confirmedStamping(forOrderWithId orderId: OrderSummary.ID) -> String? {
        
        return dataStore.stampingMethodByOrderId[orderId]
    }
    
    
    public func confirmStamping(forOrderWithId orderId: OrderSummary.ID, stamping: String) {
        
        try! dataStore.setStampingMethod(stamping, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public var dateValidatedWithoutStampingByOrderId: [OrderSummary.ID: Date] {
        
        dataStore.dateValidatedWithoutStampingByOrderId
    }
    
    
    public func validateOrderWithoutStamping(orderId: OrderDetails.ID) {
        
        try! dataStore.setDateValidatedWithoutStamping(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func dateOrderValidatedWithoutStamping(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutStampingByOrderId[orderId]
    }
    
    
    public func orderIsValidatedWithoutStamping(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutStampingByOrderId[orderId] != nil
    }
}
