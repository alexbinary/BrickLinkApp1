
import Foundation



@Observable
class UploadController {
    
    
    private let catalogStore: CatalogStore
    private let uploadStore: UploadStore
    private let inventoryStore: InventoryStore
    
    
    init(_ uploadStore: UploadStore, _ catalogStore: CatalogStore, _ inventoryStore: InventoryStore) {
        self.uploadStore = uploadStore
        self.catalogStore = catalogStore
        self.inventoryStore = inventoryStore
    }
    
    
    public var uploadItems: [UploadItem] {
        
        uploadStore.uploadItems
    }
    
    
    public var uploadedItems: [UploadedItem] {
        
        uploadStore.uploadedItems
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryStore.inventory(for: uploadItem)
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryStore.inventories(forAllColorsOf: uploadItem)
    }
    
    
    public var numberForSidebarBadge: Int {
        
        uploadItems.count
    }
    
    
    // MARK: - Upload
    
    
    public func add(_ uploadItem: UploadItem) {
        
        uploadStore.add(uploadItem)
    }
    
    
    public func delete(_ uploadItem: UploadItem) {
        
        uploadStore.delete(uploadItem)
    }
    
    
    public func update(_ uploadItem: UploadItem) {
        
        uploadStore.update(uploadItem)
    }
    
    
    public func importUploadList(fromXml xml: String) {
        
        uploadStore.importUploadList(fromXml: xml)
    }
    
    
    public var uploadItemsForList: [UploadItem] {
        
        uploadItems.sorted { item1, item2 in
                
            let rem1 = inventory(for: item1)?.remarks ?? inventories(forAllColorsOf: item1).map { $0.remarks }.sorted().first
            let rem2 = inventory(for: item2)?.remarks ?? inventories(forAllColorsOf: item2).map { $0.remarks }.sorted().first
            
            switch (rem1, rem2) {
                
            case (nil, nil):
                return true
                
            case (.some, nil):
                return true
                
            case (nil, .some):
                return false
                
            case (.some(let rem1), .some(let rem2)):
                return rem1 < rem2
            }
        }
    }
    
    
    // MARK: - Uploaded items
    
    
    public func add(_ uploadedItem: UploadedItem) {
        
        uploadStore.add(uploadedItem)
    }
    
    
    public func uploadedItemsForList(matching searchText: String) -> [UploadedItem] {
        
        uploadedItems
            .filter { $0.matches(searchText, catalogStore) }
            .sorted { $0.uploadDate > $1.uploadDate }
    }
}
