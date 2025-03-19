
import Foundation



@Observable
class ReloadController {
    
    
    private let orderStore: OrderStore
    private let feedbackStore: FeedbackStore
    private let orderController: OrderController
    private let trackingController: TrackingController
    
    
    init(orderStore: OrderStore, feedbackStore: FeedbackStore, orderController: OrderController, trackingController: TrackingController) {
        self.orderStore = orderStore
        self.feedbackStore = feedbackStore
        self.orderController = orderController
        self.trackingController = trackingController
    }
    
    
    public var orderSummaries: [OrderSummary] {
        
        orderStore.orderSummaries
    }
    
    
    public func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        orderStore.orderSummary(forOrderWithId: orderId)
    }
    
    
    public func reloadOrderSummaries() async {
        
        await orderStore.reloadOrderSummaries()
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderStore.orderDetails(forOrderWithId: orderId)
    }
    
    
    public func loadOrderDetails(forOrderWithId orderId: OrderSummary.ID) async {
        
        await orderStore.loadOrderDetails(forOrderWithId: orderId)
    }
    
    
    public func loadOrderDetailsIfMissing(forOrderWithId orderId: String) async {
        
        await orderStore.loadOrderDetailsIfMissing(forOrderWithId: orderId)
    }
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderStore.orderItems(forOrderWithId: orderId)
    }
    
    
    public func loadOrderItems(forOrderWithId orderId: OrderSummary.ID) async {
        
        await orderStore.loadOrderItems(forOrderWithId: orderId)
    }
    
    
    public func loadOrderItemsIfMissing(forOrderWithId orderId: String) async {
        
        await orderStore.loadOrderItemsIfMissing(forOrderWithId: orderId)
    }
    
    
    public func orderFeedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        feedbackStore.orderFeedbacks(forOrderWithId: orderId)
    }
    
    
    public func loadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackStore.loadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    public func loadOrderFeedbacksIfMissing(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackStore.loadOrderFeedbacksIfMissing(forOrderWithId: orderId)
    }
    
    
    public func reloadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackStore.reloadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    public func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
        orderController.macroStatus(forOrderWithId: orderId)
    }
    
    
    public func reloadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        await trackingController.reloadLaPosteTrackingStatus(forOrderWithId: orderId)
    }
    
    
    // -
    
    
    public func loadMissingOrders() async {
        
        for order in orderSummaries {
            
            await loadOrderDetailsIfMissing(forOrderWithId: order.id)
            await loadOrderItemsIfMissing(forOrderWithId: order.id)
            await loadOrderFeedbacksIfMissing(forOrderWithId: order.id)
        }
    }
    
    
    public func refreshAllOrders() async {
        
        for order in orderSummaries {
            
            await refreshOrder(orderId: order.id)
        }
    }
    
    
    public func refreshOrder(orderId: OrderSummary.ID) async {
        
        if shouldRefreshOrder(orderId: orderId) {
            
            await loadOrderDetails(forOrderWithId: orderId)
            await loadOrderItems(forOrderWithId: orderId)
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func forceRefreshOrder(orderId: OrderSummary.ID) async {
        
        await loadOrderDetails(forOrderWithId: orderId)
        await loadOrderItems(forOrderWithId: orderId)
        await loadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    public func orderIsClosedForMoreThan30Days(orderId: OrderSummary.ID) -> Bool {
        
        let orderSummary = orderSummary(forOrderWithId: orderId)!
        
        return (
            orderSummary.status.isOneOf(.completed, .cancelled, .purged)
            &&
            orderSummary.dateStatusChanged.days(to: Date()) > 30
        )
    }
    
    
    public func shouldRefreshOrder(orderId: OrderSummary.ID) -> Bool {
        
        if orderIsClosedForMoreThan30Days(orderId: orderId) {
            
            guard
                let orderDetails = orderDetails(forOrderWithId: orderId)
            else {
                return true
            }
            
            let orderItems = orderItems(forOrderWithId: orderId)
            if orderItems.isEmpty {
                
                return true
            }
            
            let orderSummary = orderSummary(forOrderWithId: orderId)!
            if orderDetails.differs(from: orderSummary) {
                
                return true
            }
            
            let feedbacks = orderFeedbacks(forOrderWithId: orderId)
            if !feedbacks.hasSellerFeedback() {
                
                return true
            }
            
            return false
            
        } else {
        
            return true
        }
    }
    
    
    public func refreshOrdersMainList() async {
        
        await reloadOrderSummaries()
        
        let allOrders = orderSummaries
        
        let ordersThatNeedRefreshLaPosteTrackingStatus = allOrders
            .filter { macroStatus(forOrderWithId: $0.id) == .inTransit }
        
        for order in ordersThatNeedRefreshLaPosteTrackingStatus {
            await reloadLaPosteTrackingStatus(forOrderWithId: order.id)
        }
        
        let ordersThatNeedRefreshFeedback = allOrders
            .filter { macroStatus(forOrderWithId: $0.id).isOneOf(.received, .giveFeedback) }
        
        for order in ordersThatNeedRefreshFeedback {
            await reloadOrderFeedbacks(forOrderWithId: order.id)
        }
    }
}
