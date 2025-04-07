
import Foundation



@Observable
@MainActor
class TrackingMiddleController {
    
    
    private let trackingCoreController: TrackingCoreController
    private let orderCoreController: OrderCoreController
    
    
    init(_ trackingCoreController: TrackingCoreController, _ orderCoreController: OrderCoreController) {
        
        self.trackingCoreController = trackingCoreController
        self.orderCoreController = orderCoreController
    }
    
    
    func details(for order: Order) -> OrderDetails? {
        
        orderCoreController.details(for: order)
    }
    
    
    func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        if let trackingNo = details(for: order)?.trackingNo {
            return trackingCoreController.laPosteTrackingStatus(forTrackingNo: trackingNo)
        }
        return nil
    }
    
    
    func loadLaPosteTrackingStatus(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        if let trackingNo = details(for: order)?.trackingNo {
            await trackingCoreController.loadLaPosteTrackingStatus(forTrackingNo: trackingNo, refetchStrategy, operationTag)
        }
    }
    
    
    func isLoadingLaPosteTrackingStatus(for order: Order) -> Bool {
        
        if let trackingNo = details(for: order)?.trackingNo {
            return trackingCoreController.isLoadingLaPosteTrackingStatus(forTrackingNo: trackingNo)
        }
        return false
    }
}
