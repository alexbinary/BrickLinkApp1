
import Foundation



@Observable
@MainActor
class StockCoreController {
    
    
    private let inventoryCoreController: InventoryCoreController
    private let pickingCoreController: PickingCoreController
    private let orderCoreController: OrderCoreController
    private let orderMacroStatusCoreController: OrderMacroStatusCoreController
    
    
    init(
        _ inventoryCoreController: InventoryCoreController,
        _ pickingCoreController: PickingCoreController,
        _ orderCoreController: OrderCoreController,
        _ orderMacroStatusCoreController: OrderMacroStatusCoreController
    ) {
        self.inventoryCoreController = inventoryCoreController
        self.pickingCoreController = pickingCoreController
        self.orderCoreController = orderCoreController
        self.orderMacroStatusCoreController = orderMacroStatusCoreController
    }
    
    
    var orderSummaries: [OrderSummary] {
        
        orderCoreController.orderSummaries
    }
    
    
    func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderCoreController.orderItems(forOrderWithId: orderId)
    }
    
    
    func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingCoreController.pickedItemIds(forOrderWithId: orderId)
    }
    
    
    func inventory(
        
        forType type: BrickLinkItemType,
        ref: String,
        comment: String?,
        colorId: String,
        condition: String
    
    ) -> InventoryItem? {
        
        inventoryCoreController.inventory(forType: type, ref: ref, comment: comment, colorId: colorId, condition: condition)
    }
    
    
    func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
        orderMacroStatusCoreController.macroStatus(forOrderWithId: orderId)
    }
    
    
    func inStockQuantity(
        
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
    
    
    func inStockQuantity(for orderItem: OrderItem) -> Int {
        
        return inStockQuantity(
            
            forType: orderItem.type,
            ref: orderItem.ref,
            comment: orderItem.comment,
            colorId: orderItem.colorId,
            condition: orderItem.condition
        )
    }
    
    
    func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int) {
        
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
