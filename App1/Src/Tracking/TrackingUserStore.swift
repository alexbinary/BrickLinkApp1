
import Foundation



@Observable
class TrackingUserStore {
    
    
    private let trackingStore: TrackingStore
    
    
    init(_ trackingStore: TrackingStore) {
        self.trackingStore = trackingStore
    }
    
    
    public func laPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) -> LaPosteTrackingStatus? {
        
        trackingStore.laPosteTrackingStatus(forOrderWithId: orderId)
    }
    
    
    public func reloadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        await trackingStore.reloadLaPosteTrackingStatus(forOrderWithId: orderId)
    }
}
