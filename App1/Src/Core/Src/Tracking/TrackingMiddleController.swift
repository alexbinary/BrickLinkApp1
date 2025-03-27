
import Foundation



@Observable
@MainActor
class TrackingMiddleController {
    
    
    private let trackingCoreController: TrackingCoreController
    private let orderCoreController: OrderCoreController
    
    
    init(_ trackingCoreController: TrackingCoreController, _ orderCoreController: OrderCoreController) {
        
        self.trackingCoreController = trackingCoreController
        self.orderCoreController = orderCoreController
    }
    
    
    func orderDetails(forOrderWithId orderId: Order.ID) -> OrderDetails? {
        
        orderCoreController.orderDetails(forOrderWithId: orderId)
    }
    
    
    func laPosteTrackingStatus(forTrackingNo trackingNo: String) -> LaPosteTrackingStatus? {
        
        trackingCoreController.laPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        await trackingCoreController.loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    func laPosteTrackingStatus(forOrderWithId orderId: Order.ID) -> LaPosteTrackingStatus? {
        
        if let order = orderDetails(forOrderWithId: orderId),
           let trackingNo = order.trackingNo {
            
            return laPosteTrackingStatus(forTrackingNo: trackingNo)
        } else {
            return nil
        }
    }
    
    
    func loadLaPosteTrackingStatus(forOrderWithId orderId: Order.ID) async {
        
        let order = orderDetails(forOrderWithId: orderId)!
        let trackingNo = order.trackingNo!
            
        await loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    func reloadLaPosteTrackingStatus(forOrderWithId orderId: Order.ID) async {
        
        await loadLaPosteTrackingStatus(forOrderWithId: orderId)
    }
}
