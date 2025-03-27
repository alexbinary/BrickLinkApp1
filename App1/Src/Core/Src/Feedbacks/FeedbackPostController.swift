
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
    
    
    func postPraiseFeedback(for order: Order) async {
        
        guard let orderDetails = orderCoreController.orderDetails(for: order) else { return }
        
        await feedbackCoreController.postFeedback(
            for: order, rating: .praise,
            comment: orderDetails.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
        )
    }
}
