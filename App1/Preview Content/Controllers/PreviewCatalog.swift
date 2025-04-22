
import SwiftUI



struct PreviewCatalog: CatalogProtocol {
    
    
    init(
        urlForImageOfItemOfType: URL? = nil,
        partData: PartData? = nil
    ) {
        self.urlForImageOfItemOfType = urlForImageOfItemOfType
        self.partData = partData
    }

    
    var allColors: [LegoColor] {
        
        return []
    }
    
    func colorName(forLegoColorId colorId: LegoColor.ID) -> String {
        
        return ""
    }
    
    func colorAndName(forLegoColorId colorId: LegoColor.ID) -> (color: Color?, name: String) {
        
        return (nil, "")
    }
    
    func loadColors(_ operationTag: OperationTag?) async {
        
    }
    
    func fetchEntry(forItemType type: ItemType, ref: String) async -> CatalogEntry? {
        
        return nil
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
