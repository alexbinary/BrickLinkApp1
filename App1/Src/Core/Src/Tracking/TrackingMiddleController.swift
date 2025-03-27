
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
    
    
    func laPosteTrackingStatus(forTrackingNo trackingNo: String) -> LaPosteTrackingStatus? {
        
        trackingCoreController.laPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        await trackingCoreController.loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        if let trackingNo = details(for: order)?.trackingNo {
            return laPosteTrackingStatus(forTrackingNo: trackingNo)
        }
        return nil
    }
    
    
    func loadLaPosteTrackingStatus(for order: Order) async {
        
        if let trackingNo = details(for: order)?.trackingNo {
            await loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
        }
    }
    
    
    func reloadLaPosteTrackingStatus(for order: Order) async {
        
        await loadLaPosteTrackingStatus(for: order)
    }
}
