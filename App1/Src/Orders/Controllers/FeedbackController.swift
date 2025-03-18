
import Foundation



@Observable
class FeedbackController {
    
    
    private let orderStore: OrderStore
    private let feedbackStore: FeedbackStore
    
    
    init(orderStore: OrderStore, feedbackStore: FeedbackStore) {
        self.orderStore = orderStore
        self.feedbackStore = feedbackStore
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderStore.orderDetails(forOrderWithId: orderId)
    }
    
    
    public func postOrderFeedback(orderId: OrderSummary.ID, rating: Int, comment: String) async {
        
        await feedbackStore.postOrderFeedback(orderId: orderId, rating: rating, comment: comment)
    }
    
    
    public func postPraiseOrderFeedback(orderId: OrderSummary.ID) async {
        
        guard let order = orderDetails(forOrderWithId: orderId) else { return }
        
        await postOrderFeedback(
            orderId: orderId, rating: 0,
            comment: order.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
        )
    }
}
