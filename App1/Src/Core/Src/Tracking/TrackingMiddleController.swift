
import Foundation



@Observable
@MainActor
class TrackingMiddleController {
    
    
    private let trackingController: TrackingController
    private let orderController: OrderController
    
    
    init(_ trackingController: TrackingController, _ orderController: OrderController) {
        
        self.trackingController = trackingController
        self.orderController = orderController
    }
    
    
    func details(for order: Order) -> OrderDetails? {
        
        orderController.details(for: order)
    }
    
    
    func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        if let trackingNo = details(for: order)?.trackingNo {
            return trackingController.laPosteTrackingStatus(forTrackingNo: trackingNo)
        }
        return nil
    }
    
    
    func loadLaPosteTrackingStatus(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        if let trackingNo = details(for: order)?.trackingNo {
            await trackingController.loadLaPosteTrackingStatus(forTrackingNo: trackingNo, refetchStrategy, operationTag)
        }
    }
    
    
    func isLoadingLaPosteTrackingStatus(for order: Order) -> Bool {
        
        if let trackingNo = details(for: order)?.trackingNo {
            return trackingController.isLoadingLaPosteTrackingStatus(forTrackingNo: trackingNo)
        }
        return false
    }
}
