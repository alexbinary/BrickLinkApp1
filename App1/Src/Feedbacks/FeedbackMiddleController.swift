
import Foundation



@Observable
class FeedbackMiddleController {
    
    
    private let orderCoreController: OrderCoreController
    private let feedbackCoreController: FeedbackCoreController
    
    
    init(_ orderCoreController: OrderCoreController, _ feedbackCoreController: FeedbackCoreController) {
        
        self.orderCoreController = orderCoreController
        self.feedbackCoreController = feedbackCoreController
    }
    
    
    // MARK: - Post feedback
    
    
    public func postFeedback(forOrderWithId orderId: OrderSummary.ID, rating: BrickLinkFeedbackRating, comment: String) async {
        
        await feedbackCoreController.postFeedback(forOrderWithId: orderId, rating: rating, comment: comment)
    }
    
    
    public func postPraiseFeedback(forOrderWithId orderId: OrderSummary.ID) async {
        
        guard let order = orderCoreController.orderDetails(forOrderWithId: orderId) else { return }
        
        await postFeedback(forOrderWithId: orderId, rating: .praise,
                           comment: order.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
        )
    }
}
