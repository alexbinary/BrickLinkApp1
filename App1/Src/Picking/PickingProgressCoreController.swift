
import Foundation



@Observable
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
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderCoreController.orderItems(forOrderWithId: orderId)
    }
    
    
    public func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingCoreController.pickedItemIds(forOrderWithId: orderId)
    }
    
    
    public func verifiedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingCoreController.verifiedItemIds(forOrderWithId: orderId)
    }
    

    public func pickingProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        let total = orderItems(forOrderWithId: orderId).count
        let picked = pickedItemIds(forOrderWithId: orderId).count
        
        return Percent(Double(picked)/Double(total))
    }
    

    public func pickingVerificationProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        let total = orderItems(forOrderWithId: orderId).count
        let verified = verifiedItemIds(forOrderWithId: orderId).count
        
        return Percent(Double(verified)/Double(total))
    }
}
