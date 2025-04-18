
import Foundation



@MainActor
protocol FeedbackStoreProtocol {
    
    func feedbacks(for order: Order) -> [Feedback]
    func buyerFeedback(for order: Order) -> Feedback?
    func sellerFeedback(for order: Order) -> Feedback?
    
    func isLoadingFeedbacks(for order: Order) -> Bool
    func softRefreshFeedbacks(for order: Order) async
    func hardRefreshFeedbacks(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag?) async

    func postPraiseFeedback(for order: Order) async
    
    func dateOrderValidatedWithoutFeedback(_ order: Order) -> Date?
    func orderIsValidatedWithoutFeedback(_ order: Order) -> Bool
    func validateOrderWithoutFeedback(_ order: Order)
}



@Observable
@MainActor
class FeedbackStore: FeedbackStoreProtocol {
    
    
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
    
    
    func isLoadingFeedbacks(for order: Order) -> Bool {
        
        feedbackController.isLoadingFeedbacks(for: order)
    }
    
    
    // MARK: - Refresh feedbacks
    
    
    private func order(withId orderId: Order.ID) -> Order? {
        
        orderController.order(withId: orderId)
    }
    
    
    private func hasFeedbacks(for order: Order) -> Bool {
        
        feedbackController.hasFeedbacks(for: order)
    }
    
    
    private func loadFeedbacks(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await feedbackController.loadFeedbacks(for: order, refetchStrategy, operationTag)
    }
    
    
    private func refreshFeedbacks(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
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
