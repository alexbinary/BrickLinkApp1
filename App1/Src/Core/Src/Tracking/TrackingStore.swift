
import Foundation



@Observable
@MainActor
public class TrackingStore {
    
    
    private let trackingCoreController: TrackingCoreController
    private let trackingMiddleController: TrackingMiddleController
    
    
    init(_ trackingCoreController: TrackingCoreController, _ trackingMiddleController: TrackingMiddleController) {
        
        self.trackingCoreController = trackingCoreController
        self.trackingMiddleController = trackingMiddleController
    }
    
    
    public func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(for: order)
    }
    
    
    public var isLoadingLaPosteTrackingStatus: Bool {
        
        trackingCoreController.isLoadingLaPosteTrackingStatus
    }
    
    
    public func isLoadingLaPosteTrackingStatus(for order: Order) -> Bool {
        
        trackingMiddleController.isLoadingLaPosteTrackingStatus(for: order)
    }
}
