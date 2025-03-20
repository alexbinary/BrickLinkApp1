
import Foundation



@Observable
class FeedbackStore {
    
    
    private let orderDataAccess: OrderDataAccess
    private let feedbackDataAccess: FeedbackDataAccess
    
    
    init(_ orderDataAccess: OrderDataAccess, _ feedbackDataAccess: FeedbackDataAccess) {
        self.orderDataAccess = orderDataAccess
        self.feedbackDataAccess = feedbackDataAccess
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderDataAccess.orderDetails(forOrderWithId: orderId)
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
    
    
    public func dateOrderValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Date? {
        
        feedbackDataAccess.dateOrderValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    public func validateOrderWithoutFeedback(orderId: OrderDetails.ID) {
        
        feedbackDataAccess.validateOrderWithoutFeedback(orderId: orderId)
    }
    
    
    public func postFeedback(forOrderWithId orderId: OrderSummary.ID, rating: Int, comment: String) async {
        
        await feedbackDataAccess.postFeedback(forOrderWithId: orderId, rating: rating, comment: comment)
    }
    
    
    public func postPraiseFeedback(forOrderWithId orderId: OrderSummary.ID) async {
        
        guard let order = orderDetails(forOrderWithId: orderId) else { return }
        
        await postFeedback(
            forOrderWithId: orderId, rating: 0,
            comment: order.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
        )
    }
}
