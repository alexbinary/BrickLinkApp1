
import Foundation



@MainActor
protocol UploadStoreProtocol {

    func suggestedLocations(forItemType type: ItemType, ref: String, comment: String?, condition: ItemCondition) -> [String]
    func suggestedLocations(for uploadItem: UploadItem) -> [String]
    var uploadItemsForList: [UploadItem] { get }
    func add(_ uploadItem: UploadItem)
    func delete(_ uploadItem: UploadItem)
    func update(_ uploadItem: UploadItem)
    func importUploadList(fromXml xml: String)
    var numberForSidebarBadge: Int { get }

    func add(_ uploadedItem: UploadedItem)
    func uploadedItemsForList(matching searchText: String) -> [UploadedItem]
}



@Observable
@MainActor
class UploadStore: UploadStoreProtocol {
    
    
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
    
    
    // MARK: - Upload
    
    
    private var uploadItems: [UploadItem] {
        
        uploadController.uploadItems
    }
    
    
    private func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryController.inventory(for: uploadItem)
    }
    
    
    private func inventoriesForAllColorsOf(
        
        itemType type: ItemType,
        ref: String,
        comment: String?,
        condition: ItemCondition
    
    ) -> [InventoryItem] {
        
        inventoryController.inventoriesForAllColorsOf(
        
            itemType: type,
            ref: ref,
            comment: comment,
            condition: condition
        )
    }
    
    
    private func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryController.inventories(forAllColorsOf: uploadItem)
    }
    
    
    func suggestedLocations(
        
        forItemType type: ItemType,
        ref: String,
        comment: String?,
        condition: ItemCondition
    
    ) -> [String] {
        
        inventoriesForAllColorsOf(
        
            itemType: type,
            ref: ref,
            comment: comment,
            condition: condition
            
        ).map(\.remarks).unique.sorted()
    }
    
    
    func suggestedLocations(for uploadItem: UploadItem) -> [String] {
        
        inventories(forAllColorsOf: uploadItem).map(\.remarks).unique.sorted()
    }
    
    
    func actualOrSuggestedLocation(for uploadItem: UploadItem) -> String? {
        
        inventory(for: uploadItem)?.remarks ?? suggestedLocations(for: uploadItem).first
    }
    
    
    var uploadItemsForList: [UploadItem] {
        
        uploadItems
            .sorted(
                firstOn: \.itemIsValid, .true_before_false,
                thenOn: { self.actualOrSuggestedLocation(for: $0) },
                sortNilFirst: false
            )
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
    
    
    private var uploadedItems: [UploadedItem] {
        
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
