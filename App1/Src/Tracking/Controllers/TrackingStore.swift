
import Foundation



@Observable
@MainActor
public class TrackingStore {
    
    
    private let trackingController: TrackingController
    private let trackingMiddleController: TrackingMiddleController
    
    
    init(_ trackingController: TrackingController, _ trackingMiddleController: TrackingMiddleController) {
        
        self.trackingController = trackingController
        self.trackingMiddleController = trackingMiddleController
    }
    
    
    public func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(for: order)
    }
    
    
    public var isLoadingLaPosteTrackingStatus: Bool {
        
        trackingController.isLoadingLaPosteTrackingStatus
    }
    
    
    public func isLoadingLaPosteTrackingStatus(for order: Order) -> Bool {
        
        trackingMiddleController.isLoadingLaPosteTrackingStatus(for: order)
    }
}
