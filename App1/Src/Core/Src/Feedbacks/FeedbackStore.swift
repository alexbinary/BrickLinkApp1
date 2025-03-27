
import Foundation



@Observable
@MainActor
public class FeedbackStore {
    
    
    private let feedbackCoreController: FeedbackCoreController
    private let feedbackPostController: FeedbackPostController
    
    
    init(
        _ feedbackCoreController: FeedbackCoreController,
        _ feedbackPostController: FeedbackPostController
    ) {
        self.feedbackCoreController = feedbackCoreController
        self.feedbackPostController = feedbackPostController
    }
    
    
    // MARK: - Read feedbacks
    
    
    public func feedbacks(forOrderWithId orderId: Order.ID) -> [Feedback] {
        
        feedbackCoreController.feedbacks(forOrderWithId: orderId)
    }
    
    
    public func buyerFeedback(forOrderWithId orderId: Order.ID) -> Feedback? {
        
        feedbackCoreController.buyerFeedback(forOrderWithId: orderId)
    }
    
    
    public func sellerFeedback(forOrderWithId orderId: Order.ID) -> Feedback? {
        
        feedbackCoreController.sellerFeedback(forOrderWithId: orderId)
    }
    
    
    // MARK: - Post feedback
    
    
    public func postPraiseFeedback(forOrderWithId orderId: Order.ID) async {
        
        await feedbackPostController.postPraiseFeedback(forOrderWithId: orderId)
    }
    
    
    // MARK: - Validation without feedback
    
    
    public func dateOrderValidatedWithoutFeedback(orderId: Order.ID) -> Date? {
        
        feedbackCoreController.dateOrderValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    public func orderIsValidatedWithoutFeedback(orderId: Order.ID) -> Bool {
        
        feedbackCoreController.orderIsValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    public func validateOrderWithoutFeedback(orderId: Order.ID) {
        
        feedbackCoreController.validateOrderWithoutFeedback(orderId: orderId)
    }
}
