
import Foundation



public struct Feedback: Identifiable, Codable {
    
    public let id: Int
    public let orderId: String
    public let from: String
    public let to: String
    public let dateRated: Date
    public let rating: FeedbackRating
    public let author: FeedbackAuthor
    public let comment: String
    
    public init(id: Int, orderId: String, from: String, to: String, dateRated: Date, rating: FeedbackRating, author: FeedbackAuthor, comment: String) {
        
        self.id = id
        self.orderId = orderId
        self.from = from
        self.to = to
        self.dateRated = dateRated
        self.rating = rating
        self.author = author
        self.comment = comment
    }
}



extension Feedback {
    
    
    init(fromBl bl: BrickLinkOrderFeedback) {
        self.init(
            id: bl.feedbackId,
            orderId: "\(bl.orderId)",
            from: bl.from,
            to: bl.to,
            dateRated: bl.dateRated,
            rating: FeedbackRating(fromBl: bl.rating),
            author: FeedbackAuthor(fromBl: bl.ratingOfBs)!,
            comment: bl.comment
        )
    }
}



public enum FeedbackAuthor: String, Codable {
    
    
    case buyer
    case seller
}



extension FeedbackAuthor {

    
    init?(fromBl bl: BrickLinkFeedbackRatingOfBS) {
        switch bl {
        case .forBuyer: self = .seller
        case .forSeller: self = .buyer
        }
    }
}



extension Array where Element == Feedback {
    
    
    public func sellerFeedback() -> Feedback? {
        
        return self.first { $0.author == .seller }
    }
    
    
    public func buyerFeedback() -> Feedback? {
        
        return self.first { $0.author == .buyer }
    }
    
    
    public func hasSellerFeedback() -> Bool {
        
        return self.sellerFeedback() != nil
    }
    
    
    public func hasBuyerFeedback() -> Bool {
        
        return self.buyerFeedback() != nil
    }
    
    
    public func hasBothSellerAndBuyerFeedback() -> Bool {
        
        return hasSellerFeedback() && self.hasBuyerFeedback()
    }
}
