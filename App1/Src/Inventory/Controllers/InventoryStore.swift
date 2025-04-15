
import Foundation
import SwiftUI



@Observable
public class InventoryStore {
    
    
    private let inventoryController: InventoryController
    private let stockController: StockController
    
    
    init(
        _ inventoryController: InventoryController,
        _ stockController: StockController
    ) {
        self.inventoryController = inventoryController
        self.stockController = stockController
    }
    
    
    // MARK: - URLs
    
    
    public func url(forInventoryItemWithId inventoryId: String) -> URL? {
        
        BrickLinkUtility.url(forInventoryItemWithId: inventoryId)
    }
    
    
    // MARK: - Read inventories
    
    
    public var allInventories: [InventoryItem] {
        
        inventoryController.allInventories
    }
    
    
    public var hasInventories: Bool {
        
        inventoryController.hasInventories
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryController.inventory(for: uploadItem)
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryController.inventories(forAllColorsOf: uploadItem)
    }
    
    
    public func loadInventories(_ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await inventoryController.loadInventories(refetchStrategy, operationTag)
    }
    
    
    public var isLoadingInventories: Bool {
        
        inventoryController.isLoadingInventories
    }
    
    
    public var isLoadingInventory: Bool {
     
        inventoryController.isLoadingInventory
    }
    
    
    public func isLoadingInventory(withId inventoryId: InventoryItem.ID) -> Bool {
     
        inventoryController.isLoadingInventory(withId: inventoryId)
    }
    
    
    // MARK: Refresh
    
    
    func refreshInventories(_ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        let strategy = hasInventories ? refetchStrategy : .forceRefetch
        
        await loadInventories(strategy, operationTag)
    }
    
    
    public func softRefreshInventories() async {
     
        await refreshInventories(.refetchOnlyIfInvalidated)
    }
    
    
    public func hardRefreshInventories(_ operationTag: OperationTag? = nil) async {
     
        await refreshInventories(.forceRefetch, operationTag)
    }
    
    
    // MARK: - Create and update inventories
    
    
    public func createInventory(ref: String, type: ItemType, colorId: String, quantity: Int, unitPrice: Float, condition: String, description: String?, remarks: String) async -> InventoryItem? {
        
        await inventoryController.createInventory(ref: ref, type: type, colorId: colorId, quantity: quantity, unitPrice: unitPrice, condition: condition, description: description, remarks: remarks)
    }
    
    
    public func updateInventory(inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float? = nil, remarks: String? = nil) async {
        
        await inventoryController.updateInventory(inventoryId: inventoryId, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks)
    }
    
    
    // MARK: - Stock
    
    
    public func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int) {
        
        stockController.inStockQuantityBeforeAfter(for: orderItem)
    }
}
