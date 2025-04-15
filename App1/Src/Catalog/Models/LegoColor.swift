
import SwiftUI



public struct LegoColor: Identifiable, Codable {
    
    
    public let id: String
    public let name: String
    public let colorCode: String
    public var color: Color { Color(fromBLCode: colorCode) }
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
