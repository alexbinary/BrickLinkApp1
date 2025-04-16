
import Foundation



@Observable
@MainActor
class TrackingStore {
    
    
    private let trackingController: TrackingController
    private let trackingMiddleController: TrackingMiddleController
    
    
    init(_ trackingController: TrackingController, _ trackingMiddleController: TrackingMiddleController) {
        
        self.trackingController = trackingController
        self.trackingMiddleController = trackingMiddleController
    }
    
    
    func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(for: order)
    }
    
    
    var isLoadingLaPosteTrackingStatus: Bool {
        
        trackingController.isLoadingLaPosteTrackingStatus
    }
    
    
    func isLoadingLaPosteTrackingStatus(for order: Order) -> Bool {
        
        trackingMiddleController.isLoadingLaPosteTrackingStatus(for: order)
    }
}
