
import Foundation



@Observable
@MainActor
public class PickingStore {
    
    
    private let pickingCoreController: PickingCoreController
    private let pickingProgressCoreController: PickingProgressCoreController
    private let orderCoreController: OrderCoreController
    
    
    init(
        _ pickingCoreController: PickingCoreController,
        _ pickingProgressCoreController: PickingProgressCoreController,
        _ orderCoreController: OrderCoreController
    ) {
        self.pickingCoreController = pickingCoreController
        self.pickingProgressCoreController = pickingProgressCoreController
        self.orderCoreController = orderCoreController
    }
    
    
    public func orderItems(for order: Order, fromItemIds itemsIds: [OrderItem.ID]) -> [OrderItem] {
        
        orderCoreController.orderItems(for: order, fromItemIds: itemsIds)
    }
    
    
    public func orderItems(for order: Order) -> [OrderItem] {
        
        orderCoreController.orderItems(for: order)
    }
    
    
    // MARK: - Pick
    
    
    public func pickedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingCoreController.pickedItemIds(for: order)
    }
    
    
    public func pickedOrderItems(for order: Order) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(for: order)
        
        return orderItems(for: order, fromItemIds: pickedIds).reversed()
    }
    
    
    public func nextOrderItemsToPick(for order: Order) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(for: order)
        
        return orderItems(for: order)
            .filter { !pickedIds.contains($0.id) }
            .sorted { $0.location < $1.location }
    }
    
    
    public func orderItemsLeftToPick(for order: Order) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(for: order)
        
        return orderItems(for: order).filter { !pickedIds.contains($0.id) }
    }
    
    
    public func pickingProgress(for order: Order) -> Percent {
        
        pickingProgressCoreController.pickingProgress(for: order)
    }
    
    
    public func totalLotsLeftToPick(for order: Order) -> Int {
        
        orderItemsLeftToPick(for: order).count
    }
    
    
    public func totalPartsLeftToPick(for order: Order) -> Int {
        
        orderItemsLeftToPick(for: order).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    public func pick(_ item: OrderItem) {
        
        pickingCoreController.pick(item)
    }
    
    
    public func unpick(_ item: OrderItem) {
        
        pickingCoreController.unpick(item)
    }
    
    
    // MARK: - Verify
    
    
    public func verifiedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingCoreController.verifiedItemIds(for: order)
    }
    
    
    public func verifiedOrderItems(for order: Order) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(for: order)
        
        return orderItems(for: order, fromItemIds: verifiedIds).reversed()
    }
    
    
    public func nextOrderItemsToVerify(for order: Order) -> [OrderItem] {
    
        let pickedIds = pickedItemIds(for: order)
        let verifiedIds = verifiedItemIds(for: order)
        
        return orderItems(for: order)
            .filter { pickedIds.contains($0.id) && !verifiedIds.contains($0.id) }
            .sorted { a, b in a.condition == "N" }
    }
    
    
    public func orderItemsLeftToVerify(for order: Order) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(for: order)
        
        return orderItems(for: order).filter { !verifiedIds.contains($0.id) }
    }
    
    
    public func pickingVerificationProgress(for order: Order) -> Percent {
        
        pickingProgressCoreController.pickingVerificationProgress(for: order)
    }
    
    
    public func totalLotsLeftToVerify(for order: Order) -> Int {
        
        orderItemsLeftToVerify(for: order).count
    }
    
    
    public func totalPartsLeftToVerify(for order: Order) -> Int {
        
        orderItemsLeftToVerify(for: order).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    public func verify(_ item: OrderItem) {
        
        pickingCoreController.verify(item)
    }
    
    
    public func unverify(_ item: OrderItem) {
        
        pickingCoreController.unverify(item)
    }
}
