
import Foundation



@MainActor
class RefundController {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    var allRefunds: [OrderRefund] {
        
        dataStore.allRefunds
    }
    
    
    func refunds(for order: Order) -> [OrderRefund] {
        
        allRefunds.filter { $0.orderId == order.id }
    }
    
    
    func create(_ refund: OrderRefund) {
        
        try! dataStore.addOrderRefund(refund)
        try! dataStore.save()
    }
}
