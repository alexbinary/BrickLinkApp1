
import Foundation
import Core



@Observable
class TrackingMiddleController {
    
    
    private let trackingCoreController: TrackingCoreController
    private let orderCoreController: OrderCoreController
    
    
    init(_ trackingCoreController: TrackingCoreController, _ orderCoreController: OrderCoreController) {
        
        self.trackingCoreController = trackingCoreController
        self.orderCoreController = orderCoreController
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderCoreController.orderDetails(forOrderWithId: orderId)
    }
    
    
    public func laPosteTrackingStatus(forTrackingNo trackingNo: String) -> LaPosteTrackingStatus? {
        
        trackingCoreController.laPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    public func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        await trackingCoreController.loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    public func laPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) -> LaPosteTrackingStatus? {
        
        if let order = orderDetails(forOrderWithId: orderId),
           let trackingNo = order.trackingNo {
            
            return laPosteTrackingStatus(forTrackingNo: trackingNo)
        } else {
            return nil
        }
    }
    
    
    public func loadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        let order = orderDetails(forOrderWithId: orderId)!
        let trackingNo = order.trackingNo!
            
        await loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    public func reloadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        await loadLaPosteTrackingStatus(forOrderWithId: orderId)
    }
}
