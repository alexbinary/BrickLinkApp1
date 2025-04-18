
import SwiftUI



struct PreviewRefundStore: RefundStoreProtocol {


    func refunds(for order: Order) -> [OrderRefund] {
        
        return []
    }
    
    func create(_ refund: OrderRefund) {
        
    }
}
