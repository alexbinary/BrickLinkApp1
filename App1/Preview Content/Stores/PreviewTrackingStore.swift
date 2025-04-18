
import SwiftUI



struct PreviewTrackingStore: TrackingStoreProtocol {


    func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        return nil
    }
    
    func isLoadingLaPosteTrackingStatus(for order: Order) -> Bool {
        
        return false
    }
}
