
import Foundation



@Observable
@MainActor
class RefundStore {
    
    
    let refundController: RefundController
    
    
    init(_ refundController: RefundController) {
        
        self.refundController = refundController
    }

    
    func refunds(for order: Order) -> [OrderRefund] {
        
        refundController.refunds(for: order)
    }

    
    func create(_ refund: OrderRefund) {
        
        refundController.create(refund)
    }
}
