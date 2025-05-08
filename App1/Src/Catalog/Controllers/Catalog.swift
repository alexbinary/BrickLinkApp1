
import Foundation
import HTMLEntities
import SwiftUI



@MainActor
protocol CatalogProtocol {
    
    var allColors: [LegoColor] { get }
    func colorName(forLegoColorId colorId: LegoColor.ID) -> String
    func colorAndName(forLegoColorId colorId: LegoColor.ID) -> (color: Color?, name: String)
    func loadColors(_ operationTag: OperationTag?) async

    func fetchEntry(for item: PartDescriptible) async -> CatalogEntry?
    func url(forImageOfItemOfType type: ItemType, ref: String, colorId: String) -> URL?
    func url(forItemOfType type: ItemType, ref: String, colorId: String?) -> URL?
    func data(forItemOfType type: ItemType, ref: String, colorId: String) -> PartData?
}



@Observable
@MainActor
class Catalog: CatalogProtocol {
    
    
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
    
    
    private func color(forLegoColorId colorId: LegoColor.ID) -> Color? {
        
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
    
    
    // MARK: - Items
    
    
    func fetchEntry(for item: PartDescriptible) async -> CatalogEntry? {
        
        #if DEBUG
        if PreviewUtils.isPreviewing {
            fatalError("Cannot fetch catalog entry in Preview mode")
        }
        #endif
        
        if let type = item.partDescriptor.type,
           let ref = item.partDescriptor.ref,
           let entry = await brickLinkAPIClient.fetchCatalogEntry(itemType: type.brickLinkItemType, ref: ref) {
            
            return CatalogEntry(fromBl: entry)
        }
        
        return nil
    }
    
    
    func url(forImageOfItemOfType type: ItemType, ref: String, colorId: String) -> URL? {
        
        BrickLinkUtility.url(forCatalogImageOfItemOfType: type.brickLinkItemType, ref: ref, colorId: colorId)
    }
    
    
    func url(forItemOfType type: ItemType, ref: String, colorId: String?) -> URL? {
        
        BrickLinkUtility.url(forItemOfType: type.brickLinkItemType, ref: ref, colorId: colorId)
    }
    

    // MARK: - Parts data
    

    func data(forItemOfType type: ItemType, ref: String, colorId: String) -> PartData? {
     
        return
            partData.first(where: { $0.matches(ref: ref, colorId: colorId) })
            ??
            partData.first(where: { $0.matches(ref: ref) })
    }
}
