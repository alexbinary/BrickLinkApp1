
import Foundation



class FeedbackPostController {
    
    
    private let feedbackController: FeedbackController
    private let orderController: OrderController
    
    
    init(
        _ feedbackController: FeedbackController,
        _ orderController: OrderController
    ) {
        self.orderController = orderController
        self.feedbackController = feedbackController
    }
    
    
    func postPraiseFeedback(for order: Order) async {
        
        let orderDetails = orderController.details(for: order)!
        
        await feedbackController.postFeedback(
            for: order, rating: .praise,
            comment: orderDetails.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
        )
    }
}
