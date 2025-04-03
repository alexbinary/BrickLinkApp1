
import Foundation
import SwiftUI



@Observable
@MainActor
public class InventoryStore {
    
    
    private let inventoryCoreController: InventoryCoreController
    private let stockCoreController: StockCoreController
    
    
    init(
        _ inventoryCoreController: InventoryCoreController,
        _ stockCoreController: StockCoreController
    ) {
        self.inventoryCoreController = inventoryCoreController
        self.stockCoreController = stockCoreController
    }
    
    
    // MARK: - URLs
    
    
    public func url(forInventoryItemWithId inventoryId: String) -> URL? {
        
        BrickLinkUtility.url(forInventoryItemWithId: inventoryId)
    }
    
    
    // MARK: - Read inventories
    
    
    public var allInventories: [InventoryItem] {
        
        inventoryCoreController.allInventories
    }
    
    
    public var hasInventories: Bool {
        
        inventoryCoreController.hasInventories
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryCoreController.inventory(for: uploadItem)
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryCoreController.inventories(forAllColorsOf: uploadItem)
    }
    
    
    public func loadInventories(_ refetchStrategy: RefetchStrategy = .forceRefetch) async {
        
        await inventoryCoreController.loadInventories(refetchStrategy)
    }
    
    
    public func reloadInventories() async {
        
        await inventoryCoreController.reloadInventories()
    }
    
    
    public var isLoadingInventories: Bool {
        
        inventoryCoreController.isLoadingInventories
    }
    
    
    public var isLoadingInventory: Bool {
     
        inventoryCoreController.isLoadingInventory
    }
    
    
    public func isLoadingInventory(withId inventoryId: InventoryItem.ID) -> Bool {
     
        inventoryCoreController.isLoadingInventory(withId: inventoryId)
    }
    
    
    // MARK: Refresh
    
    
    public func refreshInventories(_ refetchStrategy: RefetchStrategy) async {
        
        let strategy = hasInventories ? refetchStrategy : .forceRefetch
        
        await loadInventories(strategy)
    }
    
    
    // MARK: - Create and update inventories
    
    
    public func createInventory(ref: String, type: ItemType, colorId: String, quantity: Int, unitPrice: Float, condition: String, description: String?, remarks: String) async -> InventoryItem? {
        
        await inventoryCoreController.createInventory(ref: ref, type: type, colorId: colorId, quantity: quantity, unitPrice: unitPrice, condition: condition, description: description, remarks: remarks)
    }
    
    
    public func updateInventory(inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float? = nil, remarks: String? = nil) async {
        
        await inventoryCoreController.updateInventory(inventoryId: inventoryId, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks)
    }
    
    
    // MARK: - Stock
    
    
    public func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int) {
        
        stockCoreController.inStockQuantityBeforeAfter(for: orderItem)
    }
}
