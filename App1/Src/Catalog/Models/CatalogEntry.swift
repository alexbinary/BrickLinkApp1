
import Foundation



struct CatalogEntry: Sendable {
    
    
    let name: String
}



extension CatalogEntry {
    
    
    init(fromBl bl: BrickLinkCatalogItem) {
        self.init(
            name: bl.name.htmlUnescape()
        )
    }
}
