
import Foundation



struct Feedback: Identifiable, Codable {
    
    let id: Int
    let orderId: String
    let from: String
    let to: String
    let dateRated: Date
    let rating: Int
    let author: FeedbackAuthor
    let comment: String
}



enum FeedbackAuthor: String, Codable {
    
    case buyer
    case seller
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
