
import Foundation



@Observable
class OrderActionStore {
    
    
    private let orderDataAccess: OrderDataAccess
    private let orderStore: OrderStore
    private let orderChecklistStore: OrderChecklistStore
    private let feedbackController: FeedbackController
    
    
    init(_ orderDataAccess: OrderDataAccess, _ orderStore: OrderStore, _ orderChecklistStore: OrderChecklistStore, _ feedbackController: FeedbackController) {
        self.orderDataAccess = orderDataAccess
        self.orderStore = orderStore
        self.orderChecklistStore = orderChecklistStore
        self.feedbackController = feedbackController
    }
    
    
    public var orderSummaries: [OrderSummary] {
        
        orderDataAccess.orderSummaries
    }
    
    
    public func updateOrderStatus(orderId: OrderSummary.ID, status: OrderStatus) async {
        
        await orderDataAccess.updateOrderStatus(orderId: orderId, status: status)
    }
    
    
    public func sendDriveThru(orderId: OrderSummary.ID) async {
        
        await orderDataAccess.sendDriveThru(orderId: orderId)
    }
    
    
    public func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
        orderStore.macroStatus(forOrderWithId: orderId)
    }
    
    
    public func orderChecklistStamping(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistStamping(orderId)
    }
    
    
    public func orderChecklistShippingTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistShippingTransaction(orderId)
    }
    
    
    public func orderChecklistTrackingNo(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistTrackingNo(orderId)
    }
    
    
    public func postPraiseOrderFeedback(orderId: OrderSummary.ID) async {
        
        await feedbackController.postPraiseFeedback(forOrderWithId: orderId)
    }
    
    
    // --
    
    
    public var ordersThatNeedCompletedAndGiveFeedback: [OrderSummary] {
        
        orderSummaries
            .filter { macroStatus(forOrderWithId: $0.id) == .inTransitFor30PlusDays }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
    }
    
    
    public var ordersThatNeedGiveFeedback: [OrderSummary] {
        
        orderSummaries
            .filter { macroStatus(forOrderWithId: $0.id) == .giveFeedback }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
    }
    
    
    public var ordersToShipAndSendDriveThru: [OrderSummary] {
        
        orderSummaries
            .filter {
                macroStatus(forOrderWithId: $0.id) == .ship
                && orderChecklistStamping($0.id)
                && orderChecklistShippingTransaction($0.id)
                && orderChecklistTrackingNo($0.id)
            }
            .sorted { $0.date > $1.date }
    }
    
    
    public var ordersThatNeedAction: [OrderSummary] {
        
        ordersThatNeedCompletedAndGiveFeedback
        + ordersThatNeedGiveFeedback
        + ordersToShipAndSendDriveThru
    }
    
    
    public func performActionForAllOrders() async {
        
        for order in ordersThatNeedCompletedAndGiveFeedback {
        
            await updateOrderStatus(orderId: order.id, status: .completed)
            await postPraiseOrderFeedback(orderId: order.id)
        }
        
        for order in ordersThatNeedGiveFeedback {
            
            await postPraiseOrderFeedback(orderId: order.id)
        }
        
        for order in ordersToShipAndSendDriveThru {
            
            await updateOrderStatus(orderId: order.id, status: .shipped)
            await sendDriveThru(orderId: order.id)
        }
    }
}
