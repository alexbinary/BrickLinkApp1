
import SwiftUI



struct LegoColor: Identifiable, Codable {
    
    
    let id: String
    let name: String
    let colorCode: String
    var color: Color { Color(fromBLCode: colorCode) }
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
