
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
    
    
    func items(for order: Order) -> [OrderItem] {
        
        orderCoreController.items(for: order)
    }
    
    
    func pickedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingCoreController.pickedItemIds(for: order)
    }
    
    
    func verifiedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingCoreController.verifiedItemIds(for: order)
    }
    

    func pickingProgress(for order: Order) -> Percent {
        
        let total = items(for: order).count
        let picked = pickedItemIds(for: order).count
        
        return Percent(Double(picked)/Double(total))
    }
    

    func pickingVerificationProgress(for order: Order) -> Percent {
        
        let total = items(for: order).count
        let verified = verifiedItemIds(for: order).count
        
        return Percent(Double(verified)/Double(total))
    }
}
