
import Foundation



struct Feedback: Identifiable, Codable {
    
    let id: Int
    let orderId: String
    let from: String
    let to: String
    let dateRated: Date
    let rating: FeedbackRating
    let author: FeedbackAuthor
    let comment: String
    
    init(id: Int, orderId: String, from: String, to: String, dateRated: Date, rating: FeedbackRating, author: FeedbackAuthor, comment: String) {
        
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



enum FeedbackAuthor: String, Codable {
    
    
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
    

    func sellerFeedback() -> Feedback? {
        
        return self.first { $0.author == .seller }
    }

    
    func buyerFeedback() -> Feedback? {
        
        return self.first { $0.author == .buyer }
    }

    
    func hasSellerFeedback() -> Bool {
        
        return self.sellerFeedback() != nil
    }

    
    func hasBuyerFeedback() -> Bool {
        
        return self.buyerFeedback() != nil
    }
    
    
    func hasBothSellerAndBuyerFeedback() -> Bool {
        
        return hasSellerFeedback() && self.hasBuyerFeedback()
    }
}
