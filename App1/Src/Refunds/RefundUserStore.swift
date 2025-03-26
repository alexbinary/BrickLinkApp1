
import Foundation
import Core



@Observable
@MainActor
class RefundUserStore {
    
    
    let refundCoreController: RefundCoreController
    
    
    init(_ refundCoreController: RefundCoreController) {
        
        self.refundCoreController = refundCoreController
    }
    
    
    public func refunds(for order: OrderDetails) -> [OrderRefund] {
        
        refundCoreController.refunds(for: order)
    }
    
    
    public func create(_ refund: OrderRefund) {
        
        refundCoreController.create(refund)
    }
}
