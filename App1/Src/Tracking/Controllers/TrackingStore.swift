
import Foundation



@MainActor
protocol TrackingStoreProtocol {

    func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus?
    func isLoadingLaPosteTrackingStatus(for order: Order) -> Bool
}



@Observable
@MainActor
class TrackingStore: TrackingStoreProtocol {
    
    
    private let trackingController: TrackingController
    private let trackingMiddleController: TrackingMiddleController
    
    
    init(_ trackingController: TrackingController, _ trackingMiddleController: TrackingMiddleController) {
        
        self.trackingController = trackingController
        self.trackingMiddleController = trackingMiddleController
    }
    
    
    func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(for: order)
    }
    
    
    func isLoadingLaPosteTrackingStatus(for order: Order) -> Bool {
        
        trackingMiddleController.isLoadingLaPosteTrackingStatus(for: order)
    }
}
