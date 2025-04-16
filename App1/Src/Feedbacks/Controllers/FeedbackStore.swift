
import Foundation



@Observable
@MainActor
class FeedbackStore {
    
    
    private let feedbackController: FeedbackController
    private let feedbackPostController: FeedbackPostController
    private let orderController: OrderController
    
    
    init(
        _ feedbackController: FeedbackController,
        _ feedbackPostController: FeedbackPostController,
        _ orderController: OrderController
    ) {
        self.feedbackController = feedbackController
        self.feedbackPostController = feedbackPostController
        self.orderController = orderController
    }
    
    
    // MARK: - Read feedbacks
    
    
    func feedbacks(for order: Order) -> [Feedback] {
        
        feedbackController.feedbacks(for: order)
    }
    
    
    func buyerFeedback(for order: Order) -> Feedback? {
        
        feedbackController.buyerFeedback(for: order)
    }
    
    
    func sellerFeedback(for order: Order) -> Feedback? {
        
        feedbackController.sellerFeedback(for: order)
    }
    
    
    var isLoadingOrderFeedbacks: Bool {
        
        feedbackController.isLoadingOrderFeedbacks
    }
    
    
    func isLoadingFeedbacks(for order: Order) -> Bool {
        
        feedbackController.isLoadingFeedbacks(for: order)
    }
    
    
    // MARK: - Refresh feedbacks
    
    
    func order(withId orderId: Order.ID) -> Order? {
        
        orderController.order(withId: orderId)
    }
    
    
    func hasFeedbacks(for order: Order) -> Bool {
        
        feedbackController.hasFeedbacks(for: order)
    }
    
    
    func loadFeedbacks(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await feedbackController.loadFeedbacks(for: order, refetchStrategy, operationTag)
    }
    
    
    func refreshFeedbacks(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        let strategy = hasFeedbacks(for: order) ? refetchStrategy : .forceRefetch
        
        await loadFeedbacks(for: order, strategy, operationTag)
    }
    
    
    func softRefreshFeedbacks(for order: Order) async {
        
        await refreshFeedbacks(for: order, .refetchOnlyIfInvalidated)
    }
    
    
    func softRefreshFeedbacks(forOrderWithId orderId: Order.ID) async {
        
        await softRefreshFeedbacks(for: order(withId: orderId)!)
    }
    
    
    func hardRefreshFeedbacks(for order: Order, _ operationTag: OperationTag? = nil) async {
        
        await refreshFeedbacks(for: order, .forceRefetch, operationTag)
    }
    
    
    func hardRefreshFeedbacks(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag? = nil) async {
        
        await hardRefreshFeedbacks(for: order(withId: orderId)!, operationTag)
    }
    
    
    // MARK: - Post feedback
    
    
    func postPraiseFeedback(for order: Order) async {
        
        await feedbackPostController.postPraiseFeedback(for: order)
    }
    
    
    var isPostingFeedback: Bool {
        
        feedbackController.isPostingFeedback
    }
    
    
    func isPostingFeedback(for order: Order) -> Bool {
        
        feedbackController.isPostingFeedback(for: order)
    }
    
    
    // MARK: - Validation without feedback
    
    
    func dateOrderValidatedWithoutFeedback(_ order: Order) -> Date? {
        
        feedbackController.dateOrderValidatedWithoutFeedback(order)
    }
    
    
    func orderIsValidatedWithoutFeedback(_ order: Order) -> Bool {
        
        feedbackController.orderIsValidatedWithoutFeedback(order)
    }
    
    
    func validateOrderWithoutFeedback(_ order: Order) {
        
        feedbackController.validateOrderWithoutFeedback(order)
    }
}
