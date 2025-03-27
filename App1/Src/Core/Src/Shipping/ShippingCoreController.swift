
import Foundation



@MainActor
class ShippingCoreController {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    // MARK: - Shipping cost
    
    
    func confirmedShippingCost(forOrderWithId orderId: OrderSummary.ID) -> Float? {
        
        return dataStore.shippingCostsByOrderId[orderId]
    }
    
    
    func confirmShippingCost(forOrderWithId orderId: OrderSummary.ID, cost: Float) {
        
        try! dataStore.setShippingCost(cost, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    // MARK: - Stamping
    
    
    func confirmedStamping(forOrderWithId orderId: OrderSummary.ID) -> String? {
        
        return dataStore.stampingMethodByOrderId[orderId]
    }
    
    
    func confirmStamping(forOrderWithId orderId: OrderSummary.ID, stamping: String) {
        
        try! dataStore.setStampingMethod(stamping, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    var dateValidatedWithoutStampingByOrderId: [OrderSummary.ID: Date] {
        
        dataStore.dateValidatedWithoutStampingByOrderId
    }
    
    
    func validateOrderWithoutStamping(orderId: OrderDetails.ID) {
        
        try! dataStore.setDateValidatedWithoutStamping(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutStamping(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutStampingByOrderId[orderId]
    }
    
    
    func orderIsValidatedWithoutStamping(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutStampingByOrderId[orderId] != nil
    }
}
