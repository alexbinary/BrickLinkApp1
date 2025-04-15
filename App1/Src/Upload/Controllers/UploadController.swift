
import Foundation



@MainActor
class UploadController {
    

    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    // MARK: - Upload
    
    
    var uploadItems: [UploadItem] {
        
        dataStore.uploadItems
    }
    
    
    func add(_ uploadItem: UploadItem) {
        
        try! dataStore.addUploadItem(uploadItem)
        try! dataStore.save()
    }
    
    
    func delete(_ uploadItem: UploadItem) {
        
        try! dataStore.deleteUploadItem(uploadItem)
        try! dataStore.save()
    }
    
    
    func update(_ updatedItem: UploadItem) {
        
        try! dataStore.updateUploadItem(updatedItem)
        try! dataStore.save()
    }
    
    
    func importUploadList(fromXml xml: String) {
        
        print("Starting XML inventory import...")
        
        let parser = XMLParser(data: Data(xml.utf8))
        let parserDelegate = UploadListXMLParserDelegate()
        parser.delegate = parserDelegate
        
        guard parser.parse() else {
            print("parsing failed")
            return
        }
        
        let items = parserDelegate.decodedUploadItems
        
        print("imported \(items.count) items")
        
        try! dataStore.addUploadItems(items)
        try! dataStore.save()
    }
    
    
    // MARK: - Uploaded items
    
    
    var uploadedItems: [UploadedItem] {
        
        dataStore.uploadedItems
    }
    
    
    func add(_ uploadedItem: UploadedItem) {
        
        try! dataStore.addUploadedItem(uploadedItem)
        try! dataStore.save()
    }
}
