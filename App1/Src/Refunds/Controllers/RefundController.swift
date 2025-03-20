
import Foundation



@Observable
class RefundController {
    
    
    let refundDataAccess: RefundDataAccess
    
    
    init(_ refundDataAccess: RefundDataAccess) {
        self.refundDataAccess = refundDataAccess
    }
    
    
    public func refunds(for order: OrderDetails) -> [OrderRefund] {
        
        refundDataAccess.refunds(for: order)
    }
    
    
    public func create(_ refund: OrderRefund) {
        
        refundDataAccess.create(refund)
    }
}
