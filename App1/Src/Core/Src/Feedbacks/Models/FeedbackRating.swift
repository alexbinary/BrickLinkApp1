


public enum FeedbackRating: Int, Codable {
    
    
    case praise = 0
    case neutral = 1
    case complaint = 2
}



extension FeedbackRating {
    
    
    init(fromBl bl: BrickLinkFeedbackRating) {
        switch bl {
        case .praise: self = .praise
        case .neutral: self = .neutral
        case .complaint: self = .complaint
        }
    }
    
    
    var bricklinkFeedbackRating: BrickLinkFeedbackRating {
        switch self {
        case .praise: .praise
        case .neutral: .neutral
        case .complaint: .complaint
        }
    }
}
