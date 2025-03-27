
import Foundation



@Observable
@MainActor
public class TrackingStore {
    
    
    private let trackingMiddleController: TrackingMiddleController
    
    
    init(_ trackingMiddleController: TrackingMiddleController) {
        
        self.trackingMiddleController = trackingMiddleController
    }
    
    
    public func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(for: order)
    }
    
    
    public func reloadLaPosteTrackingStatus(for order: Order) async {
        
        await trackingMiddleController.reloadLaPosteTrackingStatus(for: order)
    }
}
