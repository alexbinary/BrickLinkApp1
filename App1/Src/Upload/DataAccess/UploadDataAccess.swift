
import Foundation



class UploadDataAccess {
    
    
    private let fileDataAccess: FileDataAccess
    
    
    init(_ fileDataAccess: FileDataAccess) {
        self.fileDataAccess = fileDataAccess
    }
    
    
    // MARK: - Upload
    
    
    public var uploadItems: [UploadItem] {
        
        fileDataAccess.uploadItems
    }
    
    
    public func add(_ uploadItem: UploadItem) {
        
        try! fileDataAccess.addUploadItem(uploadItem)
        try! fileDataAccess.save()
    }
    
    
    public func delete(_ uploadItem: UploadItem) {
        
        try! fileDataAccess.deleteUploadItem(uploadItem)
        try! fileDataAccess.save()
    }
    
    
    public func update(_ updatedItem: UploadItem) {
        
        try! fileDataAccess.updateUploadItem(updatedItem)
        try! fileDataAccess.save()
    }
    
    
    public func importUploadList(fromXml xml: String) {
        
        let parser = XMLParser(data: Data(xml.utf8))
        let parserDelegate = UploadListXMLParserDelegate()
        parser.delegate = parserDelegate
        
        guard parser.parse() else {
            print("parsing failed")
            return
        }
        
        try! fileDataAccess.addUploadItems(parserDelegate.decodedUploadItems)
        try! fileDataAccess.save()
    }
    
    
    // MARK: - Uploaded items
    
    
    public var uploadedItems: [UploadedItem] {
        
        fileDataAccess.uploadedItems
    }
    
    
    public func add(_ uploadedItem: UploadedItem) {
        
        try! fileDataAccess.addUploadedItem(uploadedItem)
        try! fileDataAccess.save()
    }
}
