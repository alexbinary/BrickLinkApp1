
import SwiftUI



struct LegoColor: Identifiable, Codable {
    
    let id: String
    let name: String
    let colorCode: String
    
    var color: Color { Color(fromBLCode: colorCode) }
}
