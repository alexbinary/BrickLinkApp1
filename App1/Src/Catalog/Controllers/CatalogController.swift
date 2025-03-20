
import Foundation
import SwiftUI



@Observable
class CatalogController {
    
    
    private let catalogStore: CatalogStore
    
    
    init(_ catalogStore: CatalogStore) {
        self.catalogStore = catalogStore
    }
    
    
    // MARK: - Colors
    
    
    public var allColors: [LegoColor] {
        
        catalogStore.allColors
    }
    
    
    public func color(forLegoColorId colorId: LegoColor.ID) -> Color? {
        
        catalogStore.color(forLegoColorId: colorId)
    }
    
    
    public func colorName(forLegoColorId colorId: LegoColor.ID) -> String {
        
        catalogStore.colorName(forLegoColorId: colorId)
    }
    
    
    public func loadColors() async {
        
        await catalogStore.loadColors()
    }
    
    
    // MARK: - Items
    
    
    public func getCatalogItem(forItemType type: BrickLinkItemType, ref: String) async -> CatalogItem? {
        
        await catalogStore.getCatalogItem(forItemType: type, ref: ref)
    }
}
