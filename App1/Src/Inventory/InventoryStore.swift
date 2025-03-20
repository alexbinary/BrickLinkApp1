
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
}
