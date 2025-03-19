
import Foundation



@Observable
class OrderActionController {
    
    
    private let orderStore: OrderStore
    private let orderController: OrderController
    private let orderChecklistController: OrderChecklistController
    private let feedbackController: FeedbackController
    
    
    init(_ orderStore: OrderStore, _ orderController: OrderController, _ orderChecklistController: OrderChecklistController, _ feedbackController: FeedbackController) {
        self.orderStore = orderStore
        self.orderController = orderController
        self.orderChecklistController = orderChecklistController
        self.feedbackController = feedbackController
    }
    
    
    public var orderSummaries: [OrderSummary] {
        
        orderStore.orderSummaries
    }
    
    
    public func updateOrderStatus(orderId: OrderSummary.ID, status: OrderStatus) async {
        
        await orderStore.updateOrderStatus(orderId: orderId, status: status)
    }
    
    
    public func sendDriveThru(orderId: OrderSummary.ID) async {
        
        await orderStore.sendDriveThru(orderId: orderId)
    }
    
    
    public func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
        orderController.macroStatus(forOrderWithId: orderId)
    }
    
    
    public func orderChecklistStamping(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistStamping(orderId)
    }
    
    
    public func orderChecklistShippingTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistShippingTransaction(orderId)
    }
    
    
    public func orderChecklistTrackingNo(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistTrackingNo(orderId)
    }
    
    
    public func postPraiseOrderFeedback(orderId: OrderSummary.ID) async {
        
        await feedbackController.postPraiseOrderFeedback(orderId: orderId)
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
    
    
    public var actionOrders: [OrderSummary] {
        
        orderSummaries.filter {
            macroStatus(forOrderWithId: $0.id).isOneOf(
                .ship, .pickAndPack, .validatePayment, .giveFeedback, .inTransitFor30PlusDays
            )
        }
    }
}
