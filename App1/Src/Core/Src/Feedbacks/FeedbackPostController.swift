
import Foundation



@Observable
@MainActor
class FeedbackPostController {
    
    
    private let feedbackCoreController: FeedbackCoreController
    private let orderCoreController: OrderCoreController
    
    
    init(
        _ feedbackCoreController: FeedbackCoreController,
        _ orderCoreController: OrderCoreController
    ) {
        self.orderCoreController = orderCoreController
        self.feedbackCoreController = feedbackCoreController
    }
    
    
    func postPraiseFeedback(forOrderWithId orderId: OrderSummary.ID) async {
        
        guard let order = orderCoreController.orderDetails(forOrderWithId: orderId) else { return }
        
        await feedbackCoreController.postFeedback(
            forOrderWithId: orderId, rating: .praise,
            comment: order.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
        )
    }
}
