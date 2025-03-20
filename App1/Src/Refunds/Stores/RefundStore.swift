
import Foundation



@Observable
class RefundStore {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    
    public var orderRefunds: [OrderRefund] {
        
        dataStore.orderRefunds
    }
    
    
    public func refunds(for order: OrderDetails) -> [OrderRefund] {
        
        orderRefunds.filter { $0.orderId == order.id }
    }
    
    
    public func createRefund(_ refund: OrderRefund) {
        
        try! dataStore.addOrderRefund(refund)
        try! dataStore.save()
    }
}
