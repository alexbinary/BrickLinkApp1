
import Foundation
import SwiftUI
import Core



@Observable
@MainActor
class InventoryUserStore {
    
    
    private let inventoryCoreController: InventoryCoreController
    private let stockCoreController: StockCoreController
    
    
    init(
        _ inventoryCoreController: InventoryCoreController,
        _ stockCoreController: StockCoreController
    ) {
        self.inventoryCoreController = inventoryCoreController
        self.stockCoreController = stockCoreController
    }
    
    
    // MARK: - Read inventories
    
    
    public var allInventories: [InventoryItem] {
        
        inventoryCoreController.allInventories
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryCoreController.inventory(for: uploadItem)
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryCoreController.inventories(forAllColorsOf: uploadItem)
    }
    
    
    public func loadInventories() async {
        
        await inventoryCoreController.loadInventories()
    }
    
    
    public func reloadInventories() async {
        
        await inventoryCoreController.reloadInventories()
    }
    
    
    // MARK: - Create and update inventories
    
    
    public func createInventory(ref: String, type: BrickLinkItemType, colorId: String, quantity: Int, unitPrice: Float, condition: String, description: String?, remarks: String) async -> InventoryItem? {
        
        await inventoryCoreController.createInventory(ref: ref, type: type, colorId: colorId, quantity: quantity, unitPrice: unitPrice, condition: condition, description: description, remarks: remarks)
    }
    
    
    public func updateInventory(id: InventoryItem.ID, addQuantity: Int, unitPrice: Float? = nil, remarks: String? = nil) async {
        
        await inventoryCoreController.updateInventory(id: id, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks)
    }
    
    
    // MARK: - Stock
    
    
    public func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int) {
        
        stockCoreController.inStockQuantityBeforeAfter(for: orderItem)
    }
}
