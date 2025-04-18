
import Foundation



struct PreviewInventoryStore: InventoryStoreProtocol {

    
    func url(forInventoryItemWithId inventoryId: String) -> URL? {
        
        return URL(string: "http://example.com")
    }
    
    func inventory(for uploadItem: UploadItem) -> InventoryItem? {
    
        return nil
    }
    
    func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        return []
    }
    
    func softRefreshInventories() async {
        
    }
    
    func hardRefreshInventories(_ operationTag: OperationTag?) async {
        
    }
    
    func createInventory(ref: String, type: ItemType, colorId: String, quantity: Int, unitPrice: Float, condition: String, description: String?, remarks: String) async -> InventoryItem? {
        
        return nil
    }
    
    func updateInventory(inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float?, remarks: String?) async {
        
    }
    
    func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int) {
        (4, 2)
    }
}
