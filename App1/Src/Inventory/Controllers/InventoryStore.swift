
import Foundation
import SwiftUI



@MainActor
protocol InventoryStoreProtocol {
    
    func url(forInventoryItemWithId inventoryId: String) -> URL?

    var allInventories: [InventoryItem] { get }
    func inventory(for uploadItem: UploadItem) -> InventoryItem?
    func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem]

    func softRefreshInventories() async
    func hardRefreshInventories(_ operationTag: OperationTag?) async
    
    func createInventory(ref: String, type: ItemType, colorId: String, quantity: Int, unitPrice: Float, condition: String, description: String?, remarks: String) async -> InventoryItem?
    func updateInventory(inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float?, remarks: String?) async
    
    func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int)
}



@Observable
@MainActor
class InventoryStore: InventoryStoreProtocol {
    
    
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
    
    
    func url(forInventoryItemWithId inventoryId: String) -> URL? {
        
        BrickLinkUtility.url(forInventoryItemWithId: inventoryId)
    }
    
    
    // MARK: - Read inventories
    
    
    var allInventories: [InventoryItem] {
        
        inventoryController.allInventories.sorted(by: { $0.remarks < $1.remarks })
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
    
    
    // MARK: - Stock
    
    
    func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int) {
        
        stockController.inStockQuantityBeforeAfter(for: orderItem)
    }
}
