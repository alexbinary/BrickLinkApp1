import Foundation
import HTMLEntities
import SwiftUI



@Observable
class Catalog {
    
    
    private let dataStore: DataStore
    private let updateController: UpdateController
    private let brickLinkAPIClient: BrickLinkAPIClient

    
    init(_ dataStore: DataStore, _ updateController: UpdateController, _ brickLinkAPIClient: BrickLinkAPIClient) {
        
        self.dataStore = dataStore
        self.updateController = updateController
        self.brickLinkAPIClient = brickLinkAPIClient
    }
    
    
    // MARK: - Colors
    
    
    var allColors: [LegoColor] {
        
        dataStore.colors
    }
    
    
    func color(forLegoColorId colorId: LegoColor.ID) -> Color? {
        
        if let c = dataStore.colors.first(where: { $0.id == colorId }) {
            return Color(fromBLCode: c.colorCode)
        } else {
            return nil
        }
    }
    
    
    func colorName(forLegoColorId colorId: LegoColor.ID) -> String {
        
        dataStore.colors.first(where: { $0.id == colorId })?.name ?? "\(colorId)"
    }
    
    
    func colorAndName(forLegoColorId colorId: LegoColor.ID) -> (color: Color?, name: String) {
        
        (color: color(forLegoColorId: colorId), name: colorName(forLegoColorId: colorId))
    }
    
    
    func loadColors(_ operationTag: OperationTag? = nil) async {
        
        await updateController.loadColors(operationTag)
    }
    
    
    var isLoadingColors: Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadColors
    }
    
    
    // MARK: - Items
    
    
    func fetchEntry(forItemType type: ItemType, ref: String) async -> CatalogEntry? {
        
        if let entry = await brickLinkAPIClient.fetchCatalogEntry(itemType: type.brickLinkItemType, ref: ref) {
            
            return CatalogEntry(fromBl: entry)
        }
        
        return nil
    }
    
    
    func url(forImageOfItemOfType type: ItemType, ref: String, colorId: String) -> URL? {
        
        BrickLinkUtility.url(forCatalogImageOfItemOfType: type.brickLinkItemType, ref: ref, colorId: colorId)
    }
    
    
    func url(forItemOfType type: ItemType, ref: String, colorId: String) -> URL? {
        
        BrickLinkUtility.url(forItemOfType: type.brickLinkItemType, ref: ref, colorId: colorId)
    }
    

    // MARK: - Lengths overlay
    

    func url(forRebrickableLengthOverlayForItemOfType type: ItemType, ref: String, colorId: String) -> URL? {
     
        if type == .part, let length = overlayLengthByPartRef[ref] {
            return URL(string: "https://rebrickable.com/static/img/overlays/ov_\(length).png")
        }
        return nil
    }
}
