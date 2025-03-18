
import Foundation
import SwiftUI



@Observable
class ColorStore {
    
    
    private let dataStore: DataStore
    private let blCredentials: BrickLinkAPICredentials
    
    
    init(dataStore: DataStore, blCredentials: BrickLinkAPICredentials) {
        self.dataStore = dataStore
        self.blCredentials = blCredentials
    }
    
    
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
        
        let blColors = await BrickLinkAPIClient.fetchColors(using: blCredentials)
        let colors = blColors.map { LegoColor(fromBl: $0) }
        
        try! dataStore.setColors(colors)
        try! dataStore.save()
    }
}
