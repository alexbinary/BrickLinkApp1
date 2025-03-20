
import Foundation



class ShippingStore {
    
    
    private let fileDataAccess: FileDataAccess
    
    
    init(_ fileDataAccess: FileDataAccess) {
        self.fileDataAccess = fileDataAccess
    }
    
    
    // MARK: - Shipping cost
    
    
    public func confirmedShippingCost(forOrderWithId orderId: OrderSummary.ID) -> Float? {
        
        return fileDataAccess.shippingCostsByOrderId[orderId]
    }
    
    
    public func confirmShippingCost(forOrderWithId orderId: OrderSummary.ID, cost: Float) {
        
        try! fileDataAccess.setShippingCost(cost, forOrderId: orderId)
        try! fileDataAccess.save()
    }
    
    
    // MARK: - Stamping
    
    
    public func confirmedStamping(forOrderWithId orderId: OrderSummary.ID) -> String? {
        
        return fileDataAccess.stampingMethodByOrderId[orderId]
    }
    
    
    public func confirmStamping(forOrderWithId orderId: OrderSummary.ID, stamping: String) {
        
        try! fileDataAccess.setStampingMethod(stamping, forOrderId: orderId)
        try! fileDataAccess.save()
    }
    
    
    public var dateValidatedWithoutStampingByOrderId: [OrderSummary.ID: Date] {
        
        fileDataAccess.dateValidatedWithoutStampingByOrderId
    }
    
    
    public func validateOrderWithoutStamping(orderId: OrderDetails.ID) {
        
        try! fileDataAccess.setDateValidatedWithoutStamping(Date(), forOrderId: orderId)
        try! fileDataAccess.save()
    }
    
    
    public func dateOrderValidatedWithoutStamping(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutStampingByOrderId[orderId]
    }
    
    
    public func orderIsValidatedWithoutStamping(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutStampingByOrderId[orderId] != nil
    }
}
