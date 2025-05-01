
import SwiftUI



struct PreviewUploadStore: UploadStoreProtocol {
    
    
    init(numberForSidebarBadge: Int = 0) {
        
        self.numberForSidebarBadge = numberForSidebarBadge
    }
    
    
    func suggestedLocations(
        
        forItemType type: ItemType,
        ref: String,
        comment: String?,
        condition: ItemCondition
    
    ) -> [String] {
        
        return []
    }
    
    func suggestedLocations(for uploadItem: UploadItem) -> [String] {
        
        return []
    }

    var uploadItemsForList: [UploadItem] {

        return []
    }
    
    func add(_ uploadItem: UploadItem) {
        
    }
    
    func delete(_ uploadItem: UploadItem) {
        
    }
    
    func update(_ uploadItem: UploadItem) {
        
    }
    
    func importUploadList(fromXml xml: String) {
        
    }
    
    var numberForSidebarBadge: Int
    
    func add(_ uploadedItem: UploadedItem) {
        
    }
    
    func uploadedItemsForList(matching searchText: String) -> [UploadedItem] {

        return []
    }
} 
