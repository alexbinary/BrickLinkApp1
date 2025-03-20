
import Foundation



@Observable
class RefundController {
    
    
    let refundStore: RefundStore
    
    
    init(_ refundStore: RefundStore) {
        self.refundStore = refundStore
    }
    
    
    public func refunds(for order: OrderDetails) -> [OrderRefund] {
        
        refundStore.refunds(for: order)
    }
    
    
    public func create(_ refund: OrderRefund) {
        
        refundStore.create(refund)
    }
}
