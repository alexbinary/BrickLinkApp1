
import Foundation



@MainActor
class PickingProgressController {
    
    
    private let pickingController: PickingController
    private let orderController: OrderController
    
    
    init(
        _ pickingController: PickingController,
        _ orderController: OrderController
    ) {
        self.pickingController = pickingController
        self.orderController = orderController
    }
    
    
    func items(for order: Order) -> [OrderItem] {
        
        orderController.items(for: order)
    }
    
    
    func pickedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingController.pickedItemIds(for: order)
    }
    
    
    func verifiedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingController.verifiedItemIds(for: order)
    }
    

    func pickingProgress(for order: Order) -> Percent {
        
        let picked = pickedItemIds(for: order).count
        if picked == 0 { return 0% }
        
        let total = items(for: order).count
        return Percent(Double(picked)/Double(total))
    }
    

    func pickingVerificationProgress(for order: Order) -> Percent {
        
        let verified = verifiedItemIds(for: order).count
        if verified == 0 { return 0% }
        
        let total = items(for: order).count
        return Percent(Double(verified)/Double(total))
    }
}
