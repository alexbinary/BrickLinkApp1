
import Foundation
import SwiftUI



@Observable
class Catalog {
    
    
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
    
    
    public func colorAndName(forLegoColorId colorId: LegoColor.ID) -> (color: Color?, name: String) {
        
        (color: color(forLegoColorId: colorId), name: colorName(forLegoColorId: colorId))
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
    
    
    public func fetchEntry(forItemType type: BrickLinkItemType, ref: String) async -> CatalogEntry? {
        
        if let entry = await BrickLinkAPIClient.fetchCatalogEntry(forItemType: type, ref: ref) {
            
            return CatalogEntry(fromBl: entry)
        }
        
        return nil
    }
    
    
    public func url(forImageOfItemOfType type: BrickLinkItemType, ref: String, colorId: String) -> URL? {
        
        BrickLinkUtility.url(forCatalogImageOfItemOfType: type, ref: ref, colorId: colorId)
    }
}



extension LegoColor {
    
    
    init(fromBl bl: BrickLinkColor) {
        
        self.id = "\(bl.colorId)"
        self.name = bl.colorName
        self.colorCode = bl.colorCode
    }
}



extension CatalogEntry {
    
    
    init(fromBl bl: BrickLinkCatalogItem) {
        
        self.name = bl.name.htmlUnescape()
    }
}

