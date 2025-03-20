
import Foundation
import SwiftUI



@Observable
class InventoryController {
    
    
    private let inventoryStore: InventoryStore
    
    
    init(_ inventoryStore: InventoryStore) {
        self.inventoryStore = inventoryStore
    }
    
    
    public var allInventories: [InventoryItem] {
        
        inventoryStore.allInventories
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryStore.inventory(for: uploadItem)
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryStore.inventories(forAllColorsOf: uploadItem)
    }
    
    
    public func loadInventories() async {
        
        await inventoryStore.loadInventories()
    }
    
    
    public func reloadInventories() async {
        
        await inventoryStore.reloadInventories()
    }
    
    
    public func createInventory(
        
        ref: String,
        type: BrickLinkItemType,
        colorId: String,
        quantity: Int,
        unitPrice: Float,
        condition: String,
        description: String?,
        remarks: String
        
    ) async -> InventoryItem? {
        
        await inventoryStore.createInventory(
            
            ref: ref,
            type: type,
            colorId: colorId,
            quantity: quantity,
            unitPrice: unitPrice,
            condition: condition,
            description: description,
            remarks: remarks
        )
    }
    
    
    public func updateInventory(id: InventoryItem.ID, addQuantity: Int, unitPrice: Float? = nil, remarks: String? = nil) async {
        
        await inventoryStore.updateInventory(id: id, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks)
    }
}
