
import Foundation
import SwiftUI



class CatalogStore {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    
    // MARK: - Colors
    
    
    public var allColors: [LegoColor] {
        
        dataStore.colors
    }
    
    
    public func color(forLegoColorId colorId: LegoColor.ID) -> Color? {
        
        if let c = dataStore.colors.first(where: { $0.id == colorId }) {
            return Color(fromBLCode: c.colorCode)
        } else {
            return nil
        }
    }
    
    
    public func colorName(forLegoColorId colorId: LegoColor.ID) -> String {
        
        dataStore.colors.first(where: { $0.id == colorId })?.name ?? "\(colorId)"
    }
    
    
    public func loadColors() async {
        
        print("Loading colors")
        
        let blColors = await BrickLinkAPIClient.fetchColors()
        let colors = blColors.map { LegoColor(fromBl: $0) }
        
        print("Loaded \(colors.count) colors")
        
        try! dataStore.setColors(colors)
        try! dataStore.save()
    }
    
    
    // MARK: - Items
    
    
    public func getCatalogItem(forItemType type: BrickLinkItemType, ref: String) async -> CatalogItem? {
        
        if let catalogItem = await BrickLinkAPIClient.fetchCatalogEntry(forItemType: type, ref: ref) {
            
            return CatalogItem(fromBl: catalogItem)
        }
        
        return nil
    }
}



extension LegoColor {
    
    
    init(fromBl bl: BrickLinkColor) {
        
        self.id = "\(bl.colorId)"
        self.name = bl.colorName
        self.colorCode = bl.colorCode
    }
}



extension CatalogItem {
    
    
    init(fromBl bl: BrickLinkCatalogItem) {
        
        self.name = bl.name.htmlUnescape()
    }
}
