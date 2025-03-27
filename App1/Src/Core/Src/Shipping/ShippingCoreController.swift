
import Foundation



@MainActor
class ShippingCoreController {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    // MARK: - Shipping cost
    
    
    func confirmedShippingCost(for order: Order) -> Float? {
        
        return dataStore.shippingCostsByOrderId[order.id]
    }
    
    
    func confirmShippingCost(for order: Order, cost: Float) {
        
        try! dataStore.setShippingCost(cost, forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    // MARK: - Stamping
    
    
    func confirmedStamping(for order: Order) -> String? {
        
        return dataStore.stampingMethodByOrderId[order.id]
    }
    
    
    func confirmStamping(for order: Order, stamping: String) {
        
        try! dataStore.setStampingMethod(stamping, forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    var dateValidatedWithoutStampingByOrderId: [Order.ID: Date] {
        
        dataStore.dateValidatedWithoutStampingByOrderId
    }
    
    
    func validateOrderWithoutStamping(_ order: Order) {
        
        try! dataStore.setDateValidatedWithoutStamping(Date(), forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutStamping(_ order: Order) -> Date? {
        
        return dateValidatedWithoutStampingByOrderId[order.id]
    }
    
    
    func orderIsValidatedWithoutStamping(_ order: Order) -> Bool {
        
        return dateValidatedWithoutStampingByOrderId[order.id] != nil
    }
}
