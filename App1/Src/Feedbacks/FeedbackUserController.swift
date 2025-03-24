
import Foundation



@Observable
class FeedbackUserController {
    
    
    private let orderDataAccess: OrderDataAccess
    private let feedbackDataAccess: FeedbackDataAccess
    
    
    init(_ orderDataAccess: OrderDataAccess, _ feedbackDataAccess: FeedbackDataAccess) {
        self.orderDataAccess = orderDataAccess
        self.feedbackDataAccess = feedbackDataAccess
    }
    
    
    // MARK: - Post feedback
    
    
    public func postFeedback(forOrderWithId orderId: OrderSummary.ID, rating: BrickLinkFeedbackRating, comment: String) async {
        
        await feedbackDataAccess.postFeedback(forOrderWithId: orderId, rating: rating, comment: comment)
    }
    
    
    public func postPraiseFeedback(forOrderWithId orderId: OrderSummary.ID) async {
        
        guard let order = orderDataAccess.orderDetails(forOrderWithId: orderId) else { return }
        
        await postFeedback(forOrderWithId: orderId, rating: .praise,
                           comment: order.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
        )
    }
    
    
    // MARK: - Validation without feedback
    
    
    public func dateOrderValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Date? {
        
        feedbackDataAccess.dateOrderValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    public func orderIsValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Bool {
        
        feedbackDataAccess.orderIsValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    public func validateOrderWithoutFeedback(orderId: OrderDetails.ID) {
        
        feedbackDataAccess.validateOrderWithoutFeedback(orderId: orderId)
    }
}
