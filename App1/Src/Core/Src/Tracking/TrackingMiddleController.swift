
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
    
    
    func orderDetails(for order: Order) -> OrderDetails? {
        
        orderCoreController.orderDetails(for: order)
    }
    
    
    func laPosteTrackingStatus(forTrackingNo trackingNo: String) -> LaPosteTrackingStatus? {
        
        trackingCoreController.laPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        await trackingCoreController.loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        if let order = orderDetails(for: order),
           let trackingNo = order.trackingNo {
            
            return laPosteTrackingStatus(forTrackingNo: trackingNo)
        } else {
            return nil
        }
    }
    
    
    func loadLaPosteTrackingStatus(for order: Order) async {
        
        let order = orderDetails(for: order)!
        let trackingNo = order.trackingNo!
            
        await loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    func reloadLaPosteTrackingStatus(for order: Order) async {
        
        await loadLaPosteTrackingStatus(for: order)
    }
}
