
import Foundation
import Core



class RefundCoreController {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    public var allRefunds: [OrderRefund] {
        
        dataStore.allRefunds
    }
    
    
    public func refunds(for order: OrderDetails) -> [OrderRefund] {
        
        allRefunds.filter { $0.orderId == order.id }
    }
    
    
    public func create(_ refund: OrderRefund) {
        
        try! dataStore.addOrderRefund(refund)
        try! dataStore.save()
    }
}
