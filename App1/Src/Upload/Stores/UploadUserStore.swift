
import Foundation



@Observable
class UploadUserStore {
    
    
    private let uploadStore: UploadStore
    
    
    init(_ uploadStore: UploadStore) {
        self.uploadStore = uploadStore
    }
    
    
    // MARK: - Upload
    
    
    public var uploadItemsForList: [UploadItem] {
        
        uploadStore.uploadItemsForList
    }
    
    
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
    
    
    public var numberForSidebarBadge: Int {
        
        uploadStore.numberForSidebarBadge
    }
    
    
    // MARK: - Uploaded items
    
    
    public func add(_ uploadedItem: UploadedItem) {
        
        uploadStore.add(uploadedItem)
    }
    
    
    public func uploadedItemsForList(matching searchText: String) -> [UploadedItem] {
        
        uploadStore.uploadedItemsForList(matching: searchText)
    }
}
