
import Foundation



@MainActor
class ShippingCoreController {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    // MARK: - Shipping cost
    
    
    func confirmedShippingCost(forOrderWithId orderId: Order.ID) -> Float? {
        
        return dataStore.shippingCostsByOrderId[orderId]
    }
    
    
    func confirmShippingCost(forOrderWithId orderId: Order.ID, cost: Float) {
        
        try! dataStore.setShippingCost(cost, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    // MARK: - Stamping
    
    
    func confirmedStamping(forOrderWithId orderId: Order.ID) -> String? {
        
        return dataStore.stampingMethodByOrderId[orderId]
    }
    
    
    func confirmStamping(forOrderWithId orderId: Order.ID, stamping: String) {
        
        try! dataStore.setStampingMethod(stamping, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    var dateValidatedWithoutStampingByOrderId: [Order.ID: Date] {
        
        dataStore.dateValidatedWithoutStampingByOrderId
    }
    
    
    func validateOrderWithoutStamping(orderId: Order.ID) {
        
        try! dataStore.setDateValidatedWithoutStamping(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutStamping(orderId: Order.ID) -> Date? {
        
        return dateValidatedWithoutStampingByOrderId[orderId]
    }
    
    
    func orderIsValidatedWithoutStamping(orderId: Order.ID) -> Bool {
        
        return dateValidatedWithoutStampingByOrderId[orderId] != nil
    }
}
