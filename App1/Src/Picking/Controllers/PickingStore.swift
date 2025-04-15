
import Foundation



@Observable
public class PickingStore {
    
    
    private let pickingController: PickingController
    private let pickingProgressController: PickingProgressController
    private let orderController: OrderController
    
    
    init(
        _ pickingController: PickingController,
        _ pickingProgressController: PickingProgressController,
        _ orderController: OrderController
    ) {
        self.pickingController = pickingController
        self.pickingProgressController = pickingProgressController
        self.orderController = orderController
    }
    
    
    public func items(for order: Order, fromItemIds itemsIds: [OrderItem.ID]) -> [OrderItem] {
        
        orderController.items(for: order, fromItemIds: itemsIds)
    }
    
    
    public func items(for order: Order) -> [OrderItem] {
        
        orderController.items(for: order)
    }
    
    
    // MARK: - Pick
    
    
    public func pickedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingController.pickedItemIds(for: order)
    }
    
    
    public func pickedOrderItems(for order: Order) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(for: order)
        
        return items(for: order, fromItemIds: pickedIds).reversed()
    }
    
    
    public func nextOrderItemsToPick(for order: Order) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(for: order)
        
        return items(for: order)
            .filter { !pickedIds.contains($0.id) }
            .sorted { $0.location < $1.location }
    }
    
    
    public func orderItemsLeftToPick(for order: Order) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(for: order)
        
        return items(for: order).filter { !pickedIds.contains($0.id) }
    }
    
    
    public func pickingProgress(for order: Order) -> Percent {
        
        pickingProgressController.pickingProgress(for: order)
    }
    
    
    public func totalLotsLeftToPick(for order: Order) -> Int {
        
        orderItemsLeftToPick(for: order).count
    }
    
    
    public func totalPartsLeftToPick(for order: Order) -> Int {
        
        orderItemsLeftToPick(for: order).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    public func pick(_ item: OrderItem) {
        
        pickingController.pick(item)
    }
    
    
    public func unpick(_ item: OrderItem) {
        
        pickingController.unpick(item)
    }
    
    
    // MARK: - Verify
    
    
    public func verifiedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingController.verifiedItemIds(for: order)
    }
    
    
    public func verifiedOrderItems(for order: Order) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(for: order)
        
        return items(for: order, fromItemIds: verifiedIds).reversed()
    }
    
    
    public func nextOrderItemsToVerify(for order: Order) -> [OrderItem] {
    
        let pickedIds = pickedItemIds(for: order)
        let verifiedIds = verifiedItemIds(for: order)
        
        return items(for: order)
            .filter { pickedIds.contains($0.id) && !verifiedIds.contains($0.id) }
            .sorted { a, b in a.condition == "N" }
    }
    
    
    public func orderItemsLeftToVerify(for order: Order) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(for: order)
        
        return items(for: order).filter { !verifiedIds.contains($0.id) }
    }
    
    
    public func pickingVerificationProgress(for order: Order) -> Percent {
        
        pickingProgressController.pickingVerificationProgress(for: order)
    }
    
    
    public func totalLotsLeftToVerify(for order: Order) -> Int {
        
        orderItemsLeftToVerify(for: order).count
    }
    
    
    public func totalPartsLeftToVerify(for order: Order) -> Int {
        
        orderItemsLeftToVerify(for: order).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    public func verify(_ item: OrderItem) {
        
        pickingController.verify(item)
    }
    
    
    public func unverify(_ item: OrderItem) {
        
        pickingController.unverify(item)
    }
}
