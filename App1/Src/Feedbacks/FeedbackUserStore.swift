
import Foundation



@Observable
class FeedbackUserStore {
    
    
    private let feedbackStore: FeedbackStore
    
    
    init(_ feedbackStore: FeedbackStore) {
        self.feedbackStore = feedbackStore
    }
    
    
    // MARK: - Feedbacks
    
    
    public func feedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        feedbackStore.feedbacks(forOrderWithId: orderId)
    }
    
    
    public func buyerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbackStore.buyerFeedback(forOrderWithId: orderId)
    }
    
    
    public func sellerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbackStore.sellerFeedback(forOrderWithId: orderId)
    }
}
