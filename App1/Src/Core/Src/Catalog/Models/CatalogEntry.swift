
import Foundation



public struct CatalogEntry: Sendable {
    
    
    public let name: String
}



extension CatalogEntry {
    
    
    init(fromBl bl: BrickLinkCatalogItem) {
        self.init(
            name: bl.name.htmlUnescape()
        )
    }
}
