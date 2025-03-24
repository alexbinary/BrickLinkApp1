
import Foundation
import SwiftUI



@Observable
class InventoryUserStore {
    
    
    private let inventoryStore: InventoryStore
    private let inventoryController: InventoryController
    
    
    init(_ inventoryStore: InventoryStore, _ inventoryController: InventoryController) {
        self.inventoryStore = inventoryStore
        self.inventoryController = inventoryController
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
    
    
    public func createInventory(ref: String, type: BrickLinkItemType, colorId: String, quantity: Int, unitPrice: Float, condition: String, description: String?, remarks: String) async -> InventoryItem? {
        
        await inventoryController.createInventory(ref: ref, type: type, colorId: colorId, quantity: quantity, unitPrice: unitPrice, condition: condition, description: description, remarks: remarks)
    }
    
    
    public func updateInventory(id: InventoryItem.ID, addQuantity: Int, unitPrice: Float? = nil, remarks: String? = nil) async {
        
        await inventoryController.updateInventory(id: id, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks)
    }
}
