
import Foundation
import SwiftUI



@MainActor
protocol PickingStoreProtocol: Observable {
    
    func pickedOrderItems(for order: Order) -> [OrderItem]
    func nextOrderItemsToPick(for order: Order) -> [OrderItem]
    func pickingProgress(for order: Order) -> Percent
    
    func totalPartsLeftToPick(for order: Order) -> Int
    func totalLotsLeftToPick(for order: Order) -> Int
    
    func pick(_ item: OrderItem)
    func unpick(_ item: OrderItem)
    
    func verifiedOrderItems(for order: Order) -> [OrderItem]
    func nextOrderItemsToVerify(for order: Order) -> [OrderItem]
    func pickingVerificationProgress(for order: Order) -> Percent
    
    func totalPartsLeftToVerify(for order: Order) -> Int
    func totalLotsLeftToVerify(for order: Order) -> Int

    func verify(_ item: OrderItem)
    func unverify(_ item: OrderItem)
}



@Observable
@MainActor
class PickingStore: PickingStoreProtocol {
    
    
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
    
    
    func items(for order: Order, fromItemIds itemsIds: [OrderItem.ID]) -> [OrderItem] {
        
        orderController.items(for: order, fromItemIds: itemsIds)
    }
    
    
    func items(for order: Order) -> [OrderItem] {
        
        orderController.items(for: order)
    }
    
    
    // MARK: - Pick
    
    
    func pickedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingController.pickedItemIds(for: order)
    }
    
    
    func pickedOrderItems(for order: Order) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(for: order)
        
        return items(for: order, fromItemIds: pickedIds).reversed()
    }
    
    
    func nextOrderItemsToPick(for order: Order) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(for: order)
        
        return items(for: order)
            .filter { !pickedIds.contains($0.id) }
            .sorted { $0.location < $1.location }
    }
    
    
    func orderItemsLeftToPick(for order: Order) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(for: order)
        
        return items(for: order).filter { !pickedIds.contains($0.id) }
    }
    
    
    func pickingProgress(for order: Order) -> Percent {
        
        pickingProgressController.pickingProgress(for: order)
    }
    
    
    func totalLotsLeftToPick(for order: Order) -> Int {
        
        orderItemsLeftToPick(for: order).count
    }
    
    
    func totalPartsLeftToPick(for order: Order) -> Int {
        
        orderItemsLeftToPick(for: order).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    func pick(_ item: OrderItem) {
        
        pickingController.pick(item)
    }
    
    
    func unpick(_ item: OrderItem) {
        
        pickingController.unpick(item)
    }
    
    
    // MARK: - Verify
    
    
    func verifiedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingController.verifiedItemIds(for: order)
    }
    
    
    func verifiedOrderItems(for order: Order) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(for: order)
        
        return items(for: order, fromItemIds: verifiedIds).reversed()
    }
    
    
    func nextOrderItemsToVerify(for order: Order) -> [OrderItem] {
    
        let pickedIds = pickedItemIds(for: order)
        let verifiedIds = verifiedItemIds(for: order)
        
        return items(for: order)
            .filter { pickedIds.contains($0.id) && !verifiedIds.contains($0.id) }
            .sorted { a, b in a.condition == "N" }
    }
    
    
    func orderItemsLeftToVerify(for order: Order) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(for: order)
        
        return items(for: order).filter { !verifiedIds.contains($0.id) }
    }
    
    
    func pickingVerificationProgress(for order: Order) -> Percent {
        
        pickingProgressController.pickingVerificationProgress(for: order)
    }
    
    
    func totalLotsLeftToVerify(for order: Order) -> Int {
        
        orderItemsLeftToVerify(for: order).count
    }
    
    
    func totalPartsLeftToVerify(for order: Order) -> Int {
        
        orderItemsLeftToVerify(for: order).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    func verify(_ item: OrderItem) {
        
        pickingController.verify(item)
    }
    
    
    func unverify(_ item: OrderItem) {
        
        pickingController.unverify(item)
    }
}
