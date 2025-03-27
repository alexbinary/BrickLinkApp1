
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
    
    
    var orderSummaries: [Order] {
        
        orderCoreController.orderSummaries
    }
    
    
    func orderItems(for order: Order) -> [OrderItem] {
        
        orderCoreController.orderItems(for: order)
    }
    
    
    func pickedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingCoreController.pickedItemIds(for: order)
    }
    
    
    //
    func pickedItemIds(forOrderWithId orderId: Order.ID) -> [OrderItem.ID] {
        
        pickingCoreController.pickedItemIds(forOrderWithId: orderId)
    }
    
    
    func inventory(
        
        forType type: ItemType,
        ref: String,
        comment: String?,
        colorId: String,
        condition: String
    
    ) -> InventoryItem? {
        
        inventoryCoreController.inventory(forType: type, ref: ref, comment: comment, colorId: colorId, condition: condition)
    }
    
    
    func macroStatus(for order: Order) -> OrderMacroStatus {
        
        orderMacroStatusCoreController.macroStatus(for: order)
    }
    
    
    func inStockQuantity(
        
        forType type: ItemType,
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
            
            macroStatus(for: $0).isOneOf(.validatePayment, .pickAndPack)
            
        }.flatMap { order in
            
            orderItems(for: order).filter { item in
                
                !pickedItemIds(for: order).contains(item.id)
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
