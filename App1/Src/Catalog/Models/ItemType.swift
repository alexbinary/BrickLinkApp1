


enum ItemType: String, Codable, CaseIterable {
    
    
    case part = "PART"
    case minifig = "MINIFIG"
}



extension ItemType {

    
    init(fromBl bl: BrickLinkItemType) {
        switch bl {
        case .part: self = .part
        case .minifig: self = .minifig
        }
    }
    
    
    var brickLinkItemType: BrickLinkItemType {
        switch self {
        case .minifig: .minifig
        case .part: .part
        }
    }
}
