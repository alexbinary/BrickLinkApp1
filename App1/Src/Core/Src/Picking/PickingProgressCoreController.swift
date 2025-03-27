
import Foundation



@Observable
@MainActor
class PickingProgressCoreController {
    
    
    private let pickingCoreController: PickingCoreController
    private let orderCoreController: OrderCoreController
    
    
    init(
        _ pickingCoreController: PickingCoreController,
        _ orderCoreController: OrderCoreController
    ) {
        self.pickingCoreController = pickingCoreController
        self.orderCoreController = orderCoreController
    }
    
    
    func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderCoreController.orderItems(forOrderWithId: orderId)
    }
    
    
    func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingCoreController.pickedItemIds(forOrderWithId: orderId)
    }
    
    
    func verifiedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingCoreController.verifiedItemIds(forOrderWithId: orderId)
    }
    

    func pickingProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        let total = orderItems(forOrderWithId: orderId).count
        let picked = pickedItemIds(forOrderWithId: orderId).count
        
        return Percent(Double(picked)/Double(total))
    }
    

    func pickingVerificationProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        let total = orderItems(forOrderWithId: orderId).count
        let verified = verifiedItemIds(forOrderWithId: orderId).count
        
        return Percent(Double(verified)/Double(total))
    }
}
