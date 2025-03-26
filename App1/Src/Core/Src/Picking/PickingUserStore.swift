
import Foundation



@Observable
@MainActor
public class PickingUserStore {
    
    
    private let pickingCoreController: PickingCoreController
    private let pickingProgressCoreController: PickingProgressCoreController
    private let orderCoreController: OrderCoreController
    
    
    public init(
        _ pickingCoreController: PickingCoreController,
        _ pickingProgressCoreController: PickingProgressCoreController,
        _ orderCoreController: OrderCoreController
    ) {
        self.pickingCoreController = pickingCoreController
        self.pickingProgressCoreController = pickingProgressCoreController
        self.orderCoreController = orderCoreController
    }
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID, fromItemIds itemsIds: [OrderItem.ID]) -> [OrderItem] {
        
        orderCoreController.orderItems(forOrderWithId: orderId, fromItemIds: itemsIds)
    }
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderCoreController.orderItems(forOrderWithId: orderId)
    }
    
    
    // MARK: - Pick
    
    
    public func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingCoreController.pickedItemIds(forOrderWithId: orderId)
    }
    
    
    public func pickedOrderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId, fromItemIds: pickedIds).reversed()
    }
    
    
    public func nextOrderItemsToPick(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId)
            .filter { !pickedIds.contains($0.id) }
            .sorted { $0.location < $1.location }
    }
    
    
    public func orderItemsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId).filter { !pickedIds.contains($0.id) }
    }
    
    
    public func pickingProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        pickingProgressCoreController.pickingProgress(forOrderWithId: orderId)
    }
    
    
    public func totalLotsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToPick(forOrderWithId: orderId).count
    }
    
    
    public func totalPartsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToPick(forOrderWithId: orderId).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    public func pick(_ item: OrderItem) {
        
        pickingCoreController.pick(item)
    }
    
    
    public func unpick(_ item: OrderItem) {
        
        pickingCoreController.unpick(item)
    }
    
    
    // MARK: - Verify
    
    
    public func verifiedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingCoreController.verifiedItemIds(forOrderWithId: orderId)
    }
    
    
    public func verifiedOrderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId, fromItemIds: verifiedIds).reversed()
    }
    
    
    public func nextOrderItemsToVerify(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
    
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        let verifiedIds = verifiedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId)
            .filter { pickedIds.contains($0.id) && !verifiedIds.contains($0.id) }
            .sorted { a, b in a.condition == "N" }
    }
    
    
    public func orderItemsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId).filter { !verifiedIds.contains($0.id) }
    }
    
    
    public func pickingVerificationProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        pickingProgressCoreController.pickingVerificationProgress(forOrderWithId: orderId)
    }
    
    
    public func totalLotsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToVerify(forOrderWithId: orderId).count
    }
    
    
    public func totalPartsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToVerify(forOrderWithId: orderId).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    public func verify(_ item: OrderItem) {
        
        pickingCoreController.verify(item)
    }
    
    
    public func unverify(_ item: OrderItem) {
        
        pickingCoreController.unverify(item)
    }
}
