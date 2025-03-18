
import Foundation



@Observable
class UploadController {
    
    
    private let uploadStore: UploadStore
    private let colorStore: ColorStore
    
    
    init(uploadStore: UploadStore, colorStore: ColorStore) {
        self.uploadStore = uploadStore
        self.colorStore = colorStore
    }
    
    
    public var uploadedItems: [UploadedItem] {
        
        uploadStore.uploadedItems
    }
    
    
    // MARK: - Uploaded items
    
    
    public func uploadedItemsForList(matching searchText: String) -> [UploadedItem] {
        
        uploadedItems
            .filter { $0.matches(searchText, colorStore) }
            .sorted { $0.uploadDate > $1.uploadDate }
    }
}
