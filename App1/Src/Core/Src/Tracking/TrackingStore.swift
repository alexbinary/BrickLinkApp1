
import Foundation



@Observable
@MainActor
public class TrackingStore {
    
    
    private let trackingMiddleController: TrackingMiddleController
    
    
    init(_ trackingMiddleController: TrackingMiddleController) {
        
        self.trackingMiddleController = trackingMiddleController
    }
    
    
    public func laPosteTrackingStatus(forOrderWithId orderId: Order.ID) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(forOrderWithId: orderId)
    }
    
    
    public func reloadLaPosteTrackingStatus(forOrderWithId orderId: Order.ID) async {
        
        await trackingMiddleController.reloadLaPosteTrackingStatus(forOrderWithId: orderId)
    }
}
