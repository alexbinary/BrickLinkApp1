
import Foundation



@Observable
class FeedbackUserStore {
    
    
    private let feedbackCoreController: FeedbackCoreController
    private let feedbackMiddleController: FeedbackMiddleController
    
    
    init(_ feedbackCoreController: FeedbackCoreController, _ feedbackMiddleController: FeedbackMiddleController) {
        
        self.feedbackCoreController = feedbackCoreController
        self.feedbackMiddleController = feedbackMiddleController
    }
    
    
    // MARK: - Read feedbacks
    
    
    public func feedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        feedbackCoreController.feedbacks(forOrderWithId: orderId)
    }
    
    
    public func buyerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbackCoreController.buyerFeedback(forOrderWithId: orderId)
    }
    
    
    public func sellerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbackCoreController.sellerFeedback(forOrderWithId: orderId)
    }
    
    
    // MARK: - Post feedback
    
    
    public func postPraiseFeedback(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackMiddleController.postPraiseFeedback(forOrderWithId: orderId)
    }
    
    
    // MARK: - Validation without feedback
    
    
    public func dateOrderValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Date? {
        
        feedbackCoreController.dateOrderValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    public func orderIsValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Bool {
        
        feedbackCoreController.orderIsValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    public func validateOrderWithoutFeedback(orderId: OrderDetails.ID) {
        
        feedbackCoreController.validateOrderWithoutFeedback(orderId: orderId)
    }
}
