
import Foundation



struct CatalogEntry {
    
    
    let ref: String
    let name: String
}



extension CatalogEntry {
    
    
    init(fromBl bl: BrickLinkCatalogItem) {
        self.init(
            ref: bl.no,
            name: bl.name.htmlUnescape()
        )
    }
}
