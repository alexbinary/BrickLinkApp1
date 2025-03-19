
import Foundation



@Observable
class StockController {
    
    
    private let orderStore: OrderStore
    private let pickingStore: PickingStore
    private let inventoryStore: InventoryStore
    private let orderController: OrderController
    
    
    init(_ orderStore: OrderStore, _ pickingStore: PickingStore, _ inventoryStore: InventoryStore, _ orderController: OrderController) {
        self.orderStore = orderStore
        self.pickingStore = pickingStore
        self.inventoryStore = inventoryStore
        self.orderController = orderController
    }
    
    
    public var orderSummaries: [OrderSummary] {
        
        orderStore.orderSummaries
    }
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderStore.orderItems(forOrderWithId: orderId)
    }
    
    
    public func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingStore.pickedItemIds(forOrderWithId: orderId)
    }
    
    
    public func inventory(
        
        forType type: BrickLinkItemType,
        ref: String,
        comment: String?,
        colorId: String,
        condition: String
    
    ) -> InventoryItem? {
        
        inventoryStore.inventory(forType: type, ref: ref, comment: comment, colorId: colorId, condition: condition)
    }
    
    
    public func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
        orderController.macroStatus(forOrderWithId: orderId)
    }
    
    
    public func inStockQuantity(
        
        forType type: BrickLinkItemType,
        ref: String,
        comment: String?,
        colorId: String,
        condition: String
    
    ) -> Int {
        
        let inventory = inventory(
            
            forType: type,
            ref: ref,
            comment: comment,
            colorId: colorId,
            condition: condition
        )
        
        let inventoryQty = inventory?.quantity ?? 0
        
        let itemsNotPickedYet = orderSummaries.filter {
            
            macroStatus(forOrderWithId: $0.id).isOneOf(.validatePayment, .pickAndPack)
            
        }.flatMap { order in
            
            orderItems(forOrderWithId: order.id).filter { item in
                
                !pickedItemIds(forOrderWithId: order.id).contains(item.id)
            }
        }
        
        let pendingQty = itemsNotPickedYet.filter {
            
            $0.type == type
            && $0.ref == ref
            && $0.comment == (comment ?? "")
            && $0.colorId == colorId
            && $0.condition == condition
            
        }.reduce(0, { $0 + Int($1.quantity)! })
        
        return inventoryQty + pendingQty
    }
    
    
    public func inStockQuantity(for orderItem: OrderItem) -> Int {
        
        return inStockQuantity(
            
            forType: orderItem.type,
            ref: orderItem.ref,
            comment: orderItem.comment,
            colorId: orderItem.colorId,
            condition: orderItem.condition
        )
    }
    
    
    public func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int) {
        
        let itemIsPicked = pickedItemIds(forOrderWithId: orderItem.orderId).contains(orderItem.id)
        let stock = inStockQuantity(for: orderItem)
        let qty = Int(orderItem.quantity)!
        
        if !itemIsPicked {
            return (before: stock, after: stock - qty)
        } else {
            return (before: stock + qty, after: stock)
        }
    }
}
