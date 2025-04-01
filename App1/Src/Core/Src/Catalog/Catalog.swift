
import Foundation
import HTMLEntities
import SwiftUI



@Observable
@MainActor
public class Catalog {
    
    
    private let dataStore: DataStore
    private let updateController: UpdateController
    private let brickLinkAPIClient: BrickLinkAPIClient
    
    
    init(_ dataStore: DataStore, _ updateController: UpdateController, _ brickLinkAPIClient: BrickLinkAPIClient) {
        
        self.dataStore = dataStore
        self.updateController = updateController
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
        
        await updateController.loadColors(.evenIfNotInvalidated)
    }
    
    
    public var isLoadingColors: Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadColors
    }
    
    
    // MARK: - Items
    
    
    public func fetchEntry(forItemType type: ItemType, ref: String) async -> CatalogEntry? {
        
        if let entry = await brickLinkAPIClient.fetchCatalogEntry(itemType: type.brickLinkItemType, ref: ref) {
            
            return CatalogEntry(fromBl: entry)
        }
        
        return nil
    }
    
    
    public func url(forImageOfItemOfType type: ItemType, ref: String, colorId: String) -> URL? {
        
        BrickLinkUtility.url(forCatalogImageOfItemOfType: type.brickLinkItemType, ref: ref, colorId: colorId)
    }
}
