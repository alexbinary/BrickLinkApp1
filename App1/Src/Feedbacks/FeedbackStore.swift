
import Foundation



@Observable
class FeedbackStore {
    
    
    private let feedbackDataAccess: FeedbackDataAccess
    
    
    init(_ feedbackDataAccess: FeedbackDataAccess) {
        self.feedbackDataAccess = feedbackDataAccess
    }
    
    
    public func feedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        feedbackDataAccess.feedbacks(forOrderWithId: orderId)
    }
    
    
    public func buyerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbackDataAccess.buyerFeedback(forOrderWithId: orderId)
    }
    
    
    public func sellerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbackDataAccess.sellerFeedback(forOrderWithId: orderId)
    }
}
