
import Foundation



@Observable
class FeedbackController {
    
    
    private let orderStore: OrderStore
    private let feedbackStore: FeedbackStore
    
    
    init(_ orderStore: OrderStore, _ feedbackStore: FeedbackStore) {
        self.orderStore = orderStore
        self.feedbackStore = feedbackStore
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderStore.orderDetails(forOrderWithId: orderId)
    }
    
    
    public func feedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        feedbackStore.feedbacks(forOrderWithId: orderId)
    }
    
    
    public func buyerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbackStore.buyerFeedback(forOrderWithId: orderId)
    }
    
    
    public func sellerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbackStore.sellerFeedback(forOrderWithId: orderId)
    }
    
    
    public func dateOrderValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Date? {
        
        feedbackStore.dateOrderValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    public func validateOrderWithoutFeedback(orderId: OrderDetails.ID) {
        
        feedbackStore.validateOrderWithoutFeedback(orderId: orderId)
    }
    
    
    public func postFeedback(forOrderWithId orderId: OrderSummary.ID, rating: Int, comment: String) async {
        
        await feedbackStore.postFeedback(forOrderWithId: orderId, rating: rating, comment: comment)
    }
    
    
    public func postPraiseFeedback(forOrderWithId orderId: OrderSummary.ID) async {
        
        guard let order = orderDetails(forOrderWithId: orderId) else { return }
        
        await postFeedback(
            forOrderWithId: orderId, rating: 0,
            comment: order.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
        )
    }
}
