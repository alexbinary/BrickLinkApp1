
import Foundation
import SwiftUI



@MainActor
protocol InventoryStoreProtocol {
    
    func url(forInventoryItemWithId inventoryId: String) -> URL?

    func allInventories(matching searchText: String) -> [InventoryItem]
    func inventory(for uploadItem: UploadItem) -> InventoryItem?
    func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem]

    func softRefreshInventories() async
    func hardRefreshInventories(_ operationTag: OperationTag?) async
    
    func createInventory(ref: String, type: ItemType, colorId: String, quantity: Int, unitPrice: Float, condition: String, description: String?, remarks: String) async -> InventoryItem?
    func updateInventory(inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float?, remarks: String?) async
    func isUpdatingInventory(withId inventoryId: InventoryItem.ID) -> Bool
    
    func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int)
}



@Observable
@MainActor
class InventoryStore: InventoryStoreProtocol {
    
    
    private let inventoryController: InventoryController
    private let stockController: StockController
    private let catalog: Catalog
    
    
    init(
        _ inventoryController: InventoryController,
        _ stockController: StockController,
        _ catalog: Catalog
    ) {
        self.inventoryController = inventoryController
        self.stockController = stockController
        self.catalog = catalog
    }
    
    
    // MARK: - URLs
    
    
    func url(forInventoryItemWithId inventoryId: String) -> URL? {
        
        BrickLinkUtility.url(forInventoryItemWithId: inventoryId)
    }
    
    
    // MARK: - Read inventories
    
    
    private var allInventories: [InventoryItem] {
        
        inventoryController.allInventories
    }
    
    
    func allInventories(matching searchText: String) -> [InventoryItem] {
        
        allInventories
            .filter { $0.matches(searchText, catalog) }
            .sorted(on: { Location(from: $0.remarks) }, ifNilOn: { $0.remarks })
    }
    
    
    private var hasInventories: Bool {
        
        inventoryController.hasInventories
    }
    
    
    func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryController.inventory(for: uploadItem)
    }
    
    
    func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryController.inventories(forAllColorsOf: uploadItem)
    }
    
    
    // MARK: Refresh
    
    
    private func loadInventories(_ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await inventoryController.loadInventories(refetchStrategy, operationTag)
    }
    
    
    private func refreshInventories(_ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        let strategy = hasInventories ? refetchStrategy : .forceRefetch
        
        await loadInventories(strategy, operationTag)
    }
    
    
    func softRefreshInventories() async {
     
        await refreshInventories(.refetchOnlyIfInvalidated)
    }
    
    
    func hardRefreshInventories(_ operationTag: OperationTag? = nil) async {
     
        await refreshInventories(.forceRefetch, operationTag)
    }
    
    
    // MARK: - Create and update inventories
    
    
    func createInventory(ref: String, type: ItemType, colorId: String, quantity: Int, unitPrice: Float, condition: String, description: String?, remarks: String) async -> InventoryItem? {
        
        await inventoryController.createInventory(ref: ref, type: type, colorId: colorId, quantity: quantity, unitPrice: unitPrice, condition: condition, description: description, remarks: remarks)
    }
    
    
    func updateInventory(inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float? = nil, remarks: String? = nil) async {
        
        await inventoryController.updateInventory(inventoryId: inventoryId, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks)
    }
    
    
    func isUpdatingInventory(withId inventoryId: InventoryItem.ID) -> Bool {
     
        inventoryController.isUpdatingInventory(withId: inventoryId)
    }
    
    
    // MARK: - Stock
    
    
    func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int) {
        
        stockController.inStockQuantityBeforeAfter(for: orderItem)
    }
}
