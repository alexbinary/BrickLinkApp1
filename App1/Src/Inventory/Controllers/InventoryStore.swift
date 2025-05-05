
import Foundation
import SwiftUI



@MainActor
protocol InventoryStoreProtocol {
    
    func url(forInventoryItemWithId inventoryId: String) -> URL?

    var allInventories: [InventoryItem] { get }
    func allInventories(matching searchText: String, _ searchTokens: [SearchToken]) -> [InventoryItem]
    func inventory(                forItemType type: ItemType, ref: String, comment: String?, colorId: String, condition: ItemCondition) -> InventoryItem?
    func inventory(for uploadItem: UploadItem) -> InventoryItem?
    func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem]

    func softRefreshInventories() async
    func hardRefreshInventories(_ operationTag: OperationTag?) async
    
    func createInventory(ref: String, type: ItemType, colorId: String, quantity: Int, unitPrice: Float, condition: ItemCondition, description: String?, remarks: String) async -> InventoryItem?
    func updateInventory(inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float?, remarks: String?) async
    func isUpdatingInventory(withId inventoryId: InventoryItem.ID) -> Bool
    
    func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int)
    
    func suggestedTargetLocations(forMoving inventoryItem: InventoryItem) -> [Location]
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
    
    
    var allInventories: [InventoryItem] {
        
        inventoryController.allInventories
    }
    
    
    func allInventories(matching searchText: String, _ searchTokens: [SearchToken]) -> [InventoryItem] {
        
        allInventories
            .filter { $0.matches(searchText, searchTokens, catalog) }
            .sorted(
                tryUsing: { Location(from: $0.remarks) },
                ifNilTry: { $0.remarks },
                sortNilFirst: true
            )
    }
    
    
    private var hasInventories: Bool {
        
        inventoryController.hasInventories
    }
    
    
    func inventory(
        
        forItemType type: ItemType,
        ref: String,
        comment: String?,
        colorId: String,
        condition: ItemCondition
    
    ) -> InventoryItem? {
     
        inventoryController.inventory(
            
            forType: type,
            ref: ref,
            comment: comment,
            colorId: colorId,
            condition: condition
        )
    }
    
    
    func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryController.inventory(for: uploadItem)
    }
    
    
    func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryController.inventories(forAllColorsOf: uploadItem)
    }
    
    
    func inventories(forAllColorsOf inventoryItem: InventoryItem) -> [InventoryItem] {
        
        inventoryController.inventories(forAllColorsOf: inventoryItem)
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
    
    
    func createInventory(ref: String, type: ItemType, colorId: String, quantity: Int, unitPrice: Float, condition: ItemCondition, description: String?, remarks: String) async -> InventoryItem? {
        
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
    
    
    // MARK: - Move
    
    
    func suggestedTargetLocations(forMoving inventoryItem: InventoryItem) -> [Location] {
        
        inventories(forAllColorsOf: inventoryItem).compactMap { Location(from: $0.remarks) }.unique.sorted()
    }
}
