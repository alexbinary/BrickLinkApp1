
import Foundation



@Observable
@MainActor
public class RefundStore {
    
    
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
