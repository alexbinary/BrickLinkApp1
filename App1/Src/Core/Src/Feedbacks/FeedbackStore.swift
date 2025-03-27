
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
    
    
    public func feedbacks(for order: Order) -> [Feedback] {
        
        feedbackCoreController.feedbacks(for: order)
    }
    
    
    public func buyerFeedback(for order: Order) -> Feedback? {
        
        feedbackCoreController.buyerFeedback(for: order)
    }
    
    
    public func sellerFeedback(for order: Order) -> Feedback? {
        
        feedbackCoreController.sellerFeedback(for: order)
    }
    
    
    // MARK: - Post feedback
    
    
    public func postPraiseFeedback(for order: Order) async {
        
        await feedbackPostController.postPraiseFeedback(for: order)
    }
    
    
    // MARK: - Validation without feedback
    
    
    public func dateOrderValidatedWithoutFeedback(_ order: Order) -> Date? {
        
        feedbackCoreController.dateOrderValidatedWithoutFeedback(order)
    }
    
    
    public func orderIsValidatedWithoutFeedback(_ order: Order) -> Bool {
        
        feedbackCoreController.orderIsValidatedWithoutFeedback(order)
    }
    
    
    public func validateOrderWithoutFeedback(_ order: Order) {
        
        feedbackCoreController.validateOrderWithoutFeedback(order)
    }
}
