
import SwiftUI



struct PreviewUploadStore: UploadStoreProtocol {


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
    
    var numberForSidebarBadge: Int {

        return 3
    }
    
    func add(_ uploadedItem: UploadedItem) {
        
    }
    
    func uploadedItemsForList(matching searchText: String) -> [UploadedItem] {

        return []
    }
} 
