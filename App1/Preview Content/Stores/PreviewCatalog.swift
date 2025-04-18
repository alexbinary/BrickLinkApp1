
import SwiftUI



struct PreviewCatalog: CatalogProtocol {

    
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
    
    func url(forImageOfItemOfType type: ItemType, ref: String, colorId: String) -> URL? {
        
        return URL(string: "http://example.com")
    }
    
    func url(forItemOfType type: ItemType, ref: String, colorId: String) -> URL? {
        
        return URL(string: "http://example.com")
    }
    
    func data(forItemOfType type: ItemType, ref: String, colorId: String) -> PartData? {
        
        return nil
    }
}
