
import Foundation
import HTMLEntities
import SwiftUI



@Observable
@MainActor
public class Catalog {
    
    
    private let dataStore: DataStore
    private let brickLinkAPIClient: BrickLinkAPIClient
    
    
    init(_ dataStore: DataStore, _ brickLinkAPIClient: BrickLinkAPIClient) {
        
        self.dataStore = dataStore
        self.brickLinkAPIClient = brickLinkAPIClient
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
        
        let blColors = await brickLinkAPIClient.fetchColors()
        let colors = blColors.map { LegoColor(fromBl: $0) }
        
        print("Loaded \(colors.count) colors")
        
        try! dataStore.setColors(colors)
        try! dataStore.save()
    }
    
    
    // MARK: - Items
    
    
    public func fetchEntry(forItemType type: ItemType, ref: String) async -> CatalogEntry? {
        
        if let entry = await brickLinkAPIClient.fetchCatalogEntry(forItemType: type.brickLinkItemType, ref: ref) {
            
            return CatalogEntry(fromBl: entry)
        }
        
        return nil
    }
    
    
    public func url(forImageOfItemOfType type: ItemType, ref: String, colorId: String) -> URL? {
        
        BrickLinkUtility.url(forCatalogImageOfItemOfType: type.brickLinkItemType, ref: ref, colorId: colorId)
    }
}



extension LegoColor {
    
    
    init(fromBl bl: BrickLinkColor) {
        self = .init(
            id: "\(bl.colorId)",
            name: bl.colorName,
            colorCode: bl.colorCode
        )
    }
}



extension CatalogEntry {
    
    
    init(fromBl bl: BrickLinkCatalogItem) {
        self.init(
            name: bl.name.htmlUnescape()
        )
    }
}



extension ItemType {
    
    
    var brickLinkItemType: BrickLinkItemType {
        switch self {
        case .minifig: .minifig
        case .part: .part
        }
    }
}
