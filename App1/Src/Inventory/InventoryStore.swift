
import Foundation
import SwiftUI



@Observable
class InventoryStore {
    
    
    private let inventoryDataAccess: InventoryDataAccess
    
    
    init(_ inventoryDataAccess: InventoryDataAccess) {
        self.inventoryDataAccess = inventoryDataAccess
    }
    
    
    public var allInventories: [InventoryItem] {
        
        inventoryDataAccess.allInventories
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryDataAccess.inventory(for: uploadItem)
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryDataAccess.inventories(forAllColorsOf: uploadItem)
    }
    
    
    public func loadInventories() async {
        
        await inventoryDataAccess.loadInventories()
    }
    
    
    public func reloadInventories() async {
        
        await inventoryDataAccess.reloadInventories()
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
        
        await inventoryDataAccess.createInventory(
            
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
        
        await inventoryDataAccess.updateInventory(id: id, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks)
    }
}
