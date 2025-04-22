
import SwiftUI



struct PreviewCatalog: CatalogProtocol {
    
    
    init(
        catalogEntry: CatalogEntry? = nil,
        catalogEntryLoadingDelay: TimeInterval? = nil,
        urlForImageOfItemOfType: URL? = nil,
        partData: PartData? = nil
    ) {
        self.catalogEntry = catalogEntry
        self.catalogEntryLoadingDelay = catalogEntryLoadingDelay
        self.urlForImageOfItemOfType = urlForImageOfItemOfType
        self.partData = partData
    }

    
    var allColors: [LegoColor] {
        
        return LegoColor.previewColors
    }
    
    func colorName(forLegoColorId colorId: LegoColor.ID) -> String {
        
        return ""
    }
    
    func colorAndName(forLegoColorId colorId: LegoColor.ID) -> (color: Color?, name: String) {
        
        return (nil, "")
    }
    
    func loadColors(_ operationTag: OperationTag?) async {
        
    }
    
    var catalogEntry: CatalogEntry?
    var catalogEntryLoadingDelay: TimeInterval?
    
    func fetchEntry(forItemType type: ItemType, ref: String) async -> CatalogEntry? {
        
        if let delay = catalogEntryLoadingDelay {
            try! await Task.sleep(for: .seconds(delay))
        }
        return catalogEntry
    }
    
    let urlForImageOfItemOfType: URL?
    
    func url(forImageOfItemOfType type: ItemType, ref: String, colorId: String) -> URL? {
        
        return urlForImageOfItemOfType
    }
    
    func url(forItemOfType type: ItemType, ref: String, colorId: String) -> URL? {
        
        return URL(string: "http://example.com")
    }
    
    let partData: PartData?
    
    func data(forItemOfType type: ItemType, ref: String, colorId: String) -> PartData? {
        
        return partData
    }
}
