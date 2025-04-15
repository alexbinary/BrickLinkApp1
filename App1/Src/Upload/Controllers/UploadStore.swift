
import Foundation



@Observable
class UploadStore {
    
    
    private let uploadController: UploadController
    private let inventoryController: InventoryController
    private let catalog: Catalog

    
    init(
        _ uploadController: UploadController,
        _ inventoryController: InventoryController,
        _ catalog: Catalog
    ) {
        self.uploadController = uploadController
        self.inventoryController = inventoryController
        self.catalog = catalog
    }
    
    
    func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryController.inventory(for: uploadItem)
    }
    
    
    func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryController.inventories(forAllColorsOf: uploadItem)
    }
    
    
    // MARK: - Upload
    
    
    var uploadItems: [UploadItem] {
        
        uploadController.uploadItems
    }
    
    
    var uploadItemsForList: [UploadItem] {
        
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
    
    
    func add(_ uploadItem: UploadItem) {
        
        uploadController.add(uploadItem)
    }
    
    
    func delete(_ uploadItem: UploadItem) {
        
        uploadController.delete(uploadItem)
    }
    
    
    func update(_ uploadItem: UploadItem) {
        
        uploadController.update(uploadItem)
    }
    
    
    func importUploadList(fromXml xml: String) {
        
        uploadController.importUploadList(fromXml: xml)
    }
    
    
    var numberForSidebarBadge: Int {
        
        uploadItems.count
    }
    
    
    // MARK: - Uploaded items
    
    
    var uploadedItems: [UploadedItem] {
        
        uploadController.uploadedItems
    }
    
    
    func add(_ uploadedItem: UploadedItem) {
        
        uploadController.add(uploadedItem)
    }
    
    
    func uploadedItemsForList(matching searchText: String) -> [UploadedItem] {
        
        uploadedItems
            .filter { $0.matches(searchText, catalog) }
            .sorted { $0.uploadDate > $1.uploadDate }
    }
}
