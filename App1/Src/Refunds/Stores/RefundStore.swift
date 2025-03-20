
import Foundation



class RefundStore {
    
    
    private let fileDataAccess: FileDataAccess
    
    
    init(_ fileDataAccess: FileDataAccess) {
        self.fileDataAccess = fileDataAccess
    }
    
    
    public var allRefunds: [OrderRefund] {
        
        fileDataAccess.allRefunds
    }
    
    
    public func refunds(for order: OrderDetails) -> [OrderRefund] {
        
        allRefunds.filter { $0.orderId == order.id }
    }
    
    
    public func create(_ refund: OrderRefund) {
        
        try! fileDataAccess.addOrderRefund(refund)
        try! fileDataAccess.save()
    }
}
