
import Foundation



@Observable
@MainActor
public class FeedbackStore {
    
    
    private let feedbackCoreController: FeedbackCoreController
    private let feedbackPostController: FeedbackPostController
    private let orderCoreController: OrderCoreController
    
    
    init(
        _ feedbackCoreController: FeedbackCoreController,
        _ feedbackPostController: FeedbackPostController,
        _ orderCoreController: OrderCoreController
    ) {
        self.feedbackCoreController = feedbackCoreController
        self.feedbackPostController = feedbackPostController
        self.orderCoreController = orderCoreController
    }
    
    
    // MARK: - Read feedbacks
    
    
    public func feedbacks(for order: Order) -> [Feedback] {
        
        feedbackCoreController.feedbacks(for: order)
    }
    
    
    public func buyerFeedback(for order: Order) -> Feedback? {
        
        feedbackCoreController.buyerFeedback(for: order)
    }
    
    
    public func sellerFeedback(for order: Order) -> Feedback? {
        
        feedbackCoreController.sellerFeedback(for: order)
    }
    
    
    public var isLoadingOrderFeedbacks: Bool {
        
        feedbackCoreController.isLoadingOrderFeedbacks
    }
    
    
    public func isLoadingFeedbacks(for order: Order) -> Bool {
        
        feedbackCoreController.isLoadingFeedbacks(for: order)
    }
    
    
    // MARK: - Refresh feedbacks
    
    
    func order(withId orderId: Order.ID) -> Order? {
        
        orderCoreController.order(withId: orderId)
    }
    
    
    func hasFeedbacks(for order: Order) -> Bool {
        
        feedbackCoreController.hasFeedbacks(for: order)
    }
    
    
    func loadFeedbacks(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await feedbackCoreController.loadFeedbacks(for: order, refetchStrategy, operationTag)
    }
    
    
    func refreshFeedbacks(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        let strategy = hasFeedbacks(for: order) ? refetchStrategy : .forceRefetch
        
        await loadFeedbacks(for: order, strategy, operationTag)
    }
    
    
    public func softRefreshFeedbacks(for order: Order) async {
        
        await refreshFeedbacks(for: order, .refetchOnlyIfInvalidated)
    }
    
    
    public func softRefreshFeedbacks(forOrderWithId orderId: Order.ID) async {
        
        await softRefreshFeedbacks(for: order(withId: orderId)!)
    }
    
    
    public func hardRefreshFeedbacks(for order: Order, _ operationTag: OperationTag? = nil) async {
        
        await refreshFeedbacks(for: order, .forceRefetch, operationTag)
    }
    
    
    public func hardRefreshFeedbacks(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag? = nil) async {
        
        await hardRefreshFeedbacks(for: order(withId: orderId)!, operationTag)
    }
    
    
    // MARK: - Post feedback
    
    
    public func postPraiseFeedback(for order: Order) async {
        
        await feedbackPostController.postPraiseFeedback(for: order)
    }
    
    
    public var isPostingFeedback: Bool {
        
        feedbackCoreController.isPostingFeedback
    }
    
    
    public func isPostingFeedback(for order: Order) -> Bool {
        
        feedbackCoreController.isPostingFeedback(for: order)
    }
    
    
    // MARK: - Validation without feedback
    
    
    public func dateOrderValidatedWithoutFeedback(_ order: Order) -> Date? {
        
        feedbackCoreController.dateOrderValidatedWithoutFeedback(order)
    }
    
    
    public func orderIsValidatedWithoutFeedback(_ order: Order) -> Bool {
        
        feedbackCoreController.orderIsValidatedWithoutFeedback(order)
    }
    
    
    public func validateOrderWithoutFeedback(_ order: Order) {
        
        feedbackCoreController.validateOrderWithoutFeedback(order)
    }
}
