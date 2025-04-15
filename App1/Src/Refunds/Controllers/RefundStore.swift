
import Foundation



@Observable
@MainActor
public class RefundStore {
    
    
    let refundController: RefundController
    
    
    init(_ refundController: RefundController) {
        
        self.refundController = refundController
    }
    
    
    public func refunds(for order: Order) -> [OrderRefund] {
        
        refundController.refunds(for: order)
    }
    
    
    public func create(_ refund: OrderRefund) {
        
        refundController.create(refund)
    }
}
