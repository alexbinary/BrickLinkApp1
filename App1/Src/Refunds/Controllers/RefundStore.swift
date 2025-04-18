
import Foundation



@MainActor
protocol RefundStoreProtocol {
    
    func refunds(for order: Order) -> [OrderRefund]
    func create(_ refund: OrderRefund)
}



@Observable
@MainActor
class RefundStore: RefundStoreProtocol {
    
    
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
