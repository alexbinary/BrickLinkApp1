
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
    
    
    func details(for order: Order) -> OrderDetails? {
        
        orderCoreController.details(for: order)
    }
    
    
    func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        if let trackingNo = details(for: order)?.trackingNo {
            return trackingCoreController.laPosteTrackingStatus(forTrackingNo: trackingNo)
        }
        return nil
    }
    
    
    func loadLaPosteTrackingStatus(for order: Order) async {
        
        if let trackingNo = details(for: order)?.trackingNo {
            await trackingCoreController.loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
        }
    }
    
    
    func reloadLaPosteTrackingStatus(for order: Order) async {
        
        await loadLaPosteTrackingStatus(for: order)
    }
}
