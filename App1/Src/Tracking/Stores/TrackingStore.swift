
import Foundation



@Observable
class TrackingStore {
    
    
    private let orderDataAccess: OrderDataAccess
    private let trackingDataAccess: TrackingDataAccess
    
    
    init(_ orderDataAccess: OrderDataAccess, _ trackingDataAccess: TrackingDataAccess) {
        self.orderDataAccess = orderDataAccess
        self.trackingDataAccess = trackingDataAccess
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderDataAccess.orderDetails(forOrderWithId: orderId)
    }
    
    
    public func laPosteTrackingStatus(forTrackingNo trackingNo: String) -> LaPosteTrackingStatus? {
        
        trackingDataAccess.laPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    public func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        await trackingDataAccess.loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
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
