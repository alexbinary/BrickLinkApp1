
import Foundation



@Observable
class TrackingController {
    
    
    private let orderStore: OrderStore
    private let trackingStore: TrackingStore
    
    
    init(orderStore: OrderStore, trackingStore: TrackingStore) {
        self.orderStore = orderStore
        self.trackingStore = trackingStore
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderStore.orderDetails(forOrderWithId: orderId)
    }
    
    
    public func laPosteTrackingStatus(forTrackingNo trackingNo: String) -> LaPosteTrackingStatus? {
        
        trackingStore.laPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    public func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        await trackingStore.loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    public func laPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) -> LaPosteTrackingStatus? {
        
        if let order = orderDetails(forOrderWithId: orderId),
           let trackingNo = order.trackingNo {
            
            return laPosteTrackingStatus(forTrackingNo: trackingNo)
        } else {
            return nil
        }
    }
    
    
    public func loadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        let order = orderDetails(forOrderWithId: orderId)!
        let trackingNo = order.trackingNo!
            
        await loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    public func reloadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        await loadLaPosteTrackingStatus(forOrderWithId: orderId)
    }
}
