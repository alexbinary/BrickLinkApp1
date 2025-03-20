
import Foundation
import SwiftUI



@Observable
class CatalogStore {
    
    
    private let catalogDataAccess: CatalogDataAccess
    
    
    init(_ catalogDataAccess: CatalogDataAccess) {
        self.catalogDataAccess = catalogDataAccess
    }
    
    
    // MARK: - Colors
    
    
    public var allColors: [LegoColor] {
        
        catalogDataAccess.allColors
    }
    
    
    public func color(forLegoColorId colorId: LegoColor.ID) -> Color? {
        
        catalogDataAccess.color(forLegoColorId: colorId)
    }
    
    
    public func colorName(forLegoColorId colorId: LegoColor.ID) -> String {
        
        catalogDataAccess.colorName(forLegoColorId: colorId)
    }
    
    
    public func colorAndName(forLegoColorId colorId: LegoColor.ID) -> (color: Color?, name: String) {
        
        (color: color(forLegoColorId: colorId), name: colorName(forLegoColorId: colorId))
    }
    
    
    public func loadColors() async {
        
        await catalogDataAccess.loadColors()
    }
    
    
    // MARK: - Items
    
    
    public func getCatalogItem(forItemType type: BrickLinkItemType, ref: String) async -> CatalogItem? {
        
        await catalogDataAccess.getCatalogItem(forItemType: type, ref: ref)
    }
    
    
    public func url(forCatalogImageOfItemOfType type: BrickLinkItemType, ref: String, colorId: String) -> URL? {
        
        BrickLinkUtility.url(forCatalogImageOfItemOfType: type, ref: ref, colorId: colorId)
    }
}
