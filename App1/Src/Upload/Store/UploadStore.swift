
import Foundation



@Observable
class UploadStore {
    
    
    private let dataStore: DataStore
    
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    
    // MARK: - Upload
    
    
    public var uploadItems: [UploadItem] {
        
        dataStore.uploadItems
    }
    
    
    public func addUploadItem(_ uploadItem: UploadItem) {
        
        try! dataStore.addUploadItem(uploadItem)
        try! dataStore.save()
    }
    
    
    public func deleteUploadItem(_ uploadItem: UploadItem) {
        
        try! dataStore.deleteUploadItem(uploadItem)
        try! dataStore.save()
    }
    
    
    public func updateUploadItem(_ updatedItem: UploadItem) {
        
        try! dataStore.updateUploadItem(updatedItem)
        try! dataStore.save()
    }
    
    
    public func importUploadList(fromXml xml: String) {
        
        let parser = XMLParser(data: Data(xml.utf8))
        let parserDelegate = UploadListXMLParserDelegate()
        parser.delegate = parserDelegate
        
        guard parser.parse() else {
            print("parsing failed")
            return
        }
        
        try! dataStore.addUploadItems(parserDelegate.decodedUploadItems)
        try! dataStore.save()
    }
    
    
    // MARK: - Uploaded items
    
    
    public var uploadedItems: [UploadedItem] {
        
        dataStore.uploadedItems
    }
    
    
    public func addUploadedItem(_ uploadedItem: UploadedItem) {
        
        try! dataStore.addUploadedItem(uploadedItem)
        try! dataStore.save()
    }
}
