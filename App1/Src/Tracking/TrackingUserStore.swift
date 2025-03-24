
import Foundation



@Observable
class TrackingUserStore {
    
    
    private let trackingMiddleController: TrackingMiddleController
    
    
    init(_ trackingMiddleController: TrackingMiddleController) {
        
        self.trackingMiddleController = trackingMiddleController
    }
    
    
    public func laPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(forOrderWithId: orderId)
    }
    
    
    public func reloadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        await trackingMiddleController.reloadLaPosteTrackingStatus(forOrderWithId: orderId)
    }
}
