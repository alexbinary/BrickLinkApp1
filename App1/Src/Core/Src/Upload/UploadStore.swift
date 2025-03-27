
import Foundation



@Observable
@MainActor
public class UploadStore {
    
    
    private let uploadCoreController: UploadCoreController
    private let inventoryCoreController: InventoryCoreController
    private let catalog: Catalog

    
    public init(_ uploadCoreController: UploadCoreController, _ inventoryCoreController: InventoryCoreController, _ catalog: Catalog) {
        
        self.uploadCoreController = uploadCoreController
        self.inventoryCoreController = inventoryCoreController
        self.catalog = catalog
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryCoreController.inventory(for: uploadItem)
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryCoreController.inventories(forAllColorsOf: uploadItem)
    }
    
    
    // MARK: - Upload
    
    
    public var uploadItems: [UploadItem] {
        
        uploadCoreController.uploadItems
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
    
    
    public func add(_ uploadItem: UploadItem) {
        
        uploadCoreController.add(uploadItem)
    }
    
    
    public func delete(_ uploadItem: UploadItem) {
        
        uploadCoreController.delete(uploadItem)
    }
    
    
    public func update(_ uploadItem: UploadItem) {
        
        uploadCoreController.update(uploadItem)
    }
    
    
    public func importUploadList(fromXml xml: String) {
        
        uploadCoreController.importUploadList(fromXml: xml)
    }
    
    
    public var numberForSidebarBadge: Int {
        
        uploadItems.count
    }
    
    
    // MARK: - Uploaded items
    
    
    public var uploadedItems: [UploadedItem] {
        
        uploadCoreController.uploadedItems
    }
    
    
    public func add(_ uploadedItem: UploadedItem) {
        
        uploadCoreController.add(uploadedItem)
    }
    
    
    public func uploadedItemsForList(matching searchText: String) -> [UploadedItem] {
        
        uploadedItems
            .filter { $0.matches(searchText, catalog) }
            .sorted { $0.uploadDate > $1.uploadDate }
    }
}
