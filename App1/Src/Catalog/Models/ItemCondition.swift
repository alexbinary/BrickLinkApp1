
import SwiftUI



enum ItemCondition: String, Codable, CaseIterable {
    
    
    case new = "N"
    case used = "U"
    
    
    var name: String {
        switch self {
        case .new: "new"
        case .used: "used"
        }
    }
    
    
    var color: Color {
        switch self {
        case .used: return .red
        case .new: return .blue
        }
    }
}



extension ItemCondition {

    
    init(fromBl bl: BrickLinkItemCondition) {
        switch bl {
        case .new: self = .new
        case .used: self = .used
        }
    }
    
    
    var brickLinkItemCondition: BrickLinkItemCondition {
        switch self {
        case .new: .new
        case .used: .used
        }
    }
}
