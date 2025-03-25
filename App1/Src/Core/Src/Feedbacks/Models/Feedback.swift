
import Foundation



public struct Feedback: Identifiable, Codable {
    
    public let id: Int
    public let orderId: String
    public let from: String
    public let to: String
    public let dateRated: Date
    public let rating: BrickLinkFeedbackRating
    public let author: FeedbackAuthor
    public let comment: String
    
    public init(id: Int, orderId: String, from: String, to: String, dateRated: Date, rating: BrickLinkFeedbackRating, author: FeedbackAuthor, comment: String) {
     
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



public enum FeedbackAuthor: String, Codable {
    
    case buyer
    case seller
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
