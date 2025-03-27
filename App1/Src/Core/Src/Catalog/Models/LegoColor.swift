
import SwiftUI



public struct LegoColor: Identifiable, Codable {
    
    
    public let id: String
    public let name: String
    public let colorCode: String
    public var color: Color { Color(fromBLCode: colorCode) }
}
