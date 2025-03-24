
import Foundation



@Observable
class FeedbackUserStore {
    
    
    private let feedbackStore: FeedbackStore
    private let feedbackController: FeedbackController
    
    
    init(_ feedbackStore: FeedbackStore, _ feedbackController: FeedbackController) {
        self.feedbackStore = feedbackStore
        self.feedbackController = feedbackController
    }
    
    
    // MARK: - Read feedbacks
    
    
    public func feedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        feedbackStore.feedbacks(forOrderWithId: orderId)
    }
    
    
    public func buyerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbackStore.buyerFeedback(forOrderWithId: orderId)
    }
    
    
    public func sellerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbackStore.sellerFeedback(forOrderWithId: orderId)
    }
    
    
    // MARK: - Post feedback
    
    
    public func postPraiseFeedback(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackController.postPraiseFeedback(forOrderWithId: orderId)
    }
    
    
    // MARK: - Validation without feedback
    
    
    public func dateOrderValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Date? {
        
        feedbackController.dateOrderValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    public func orderIsValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Bool {
        
        feedbackController.orderIsValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    public func validateOrderWithoutFeedback(orderId: OrderDetails.ID) {
        
        feedbackController.validateOrderWithoutFeedback(orderId: orderId)
    }
}
