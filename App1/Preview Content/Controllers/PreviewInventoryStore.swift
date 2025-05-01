
import Foundation



struct PreviewInventoryStore: InventoryStoreProtocol {

    
    func url(forInventoryItemWithId inventoryId: String) -> URL? {
        
        return URL(string: "http://example.com")
    }
    
    var allInventories: [InventoryItem] {
        
        return []
    }
    
    func allInventories(matching searchText: String, _ searchTokens: [SearchToken]) -> [InventoryItem] {
        
        return [
            .previewItem1,
        ]
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
    
    func createInventory(ref: String, type: ItemType, colorId: String, quantity: Int, unitPrice: Float, condition: ItemCondition, description: String?, remarks: String) async -> InventoryItem? {
        
        return nil
    }
    
    func updateInventory(inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float?, remarks: String?) async {
        
    }
    
    func isUpdatingInventory(withId inventoryId: InventoryItem.ID) -> Bool {
        
        return false
    }
    
    func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int) {
        
        return (4, 2)
    }
    
    func suggestedTargetLocations(forMoving inventoryItem: InventoryItem) -> [Location] {
        
        return []
    }
}
