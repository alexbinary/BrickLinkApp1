
import Foundation



@Observable
class OrderUserStore {
    
    
    private let orderCoreController: OrderCoreController
    private let orderChecklistCoreController: OrderChecklistCoreController
    private let orderMacroStatusCoreController: OrderMacroStatusCoreController
    private let pickingProgressCoreController: PickingProgressCoreController
    private let trackingMiddleController: TrackingMiddleController
    private let feedbackCoreController: FeedbackCoreController
    private let feedbackPostController: FeedbackPostController
    
    
    init(
        _ orderCoreController: OrderCoreController,
        _ orderChecklistCoreController: OrderChecklistCoreController,
        _ orderMacroStatusCoreController: OrderMacroStatusCoreController,
        _ pickingProgressCoreController: PickingProgressCoreController,
        _ trackingMiddleController: TrackingMiddleController,
        _ feedbackCoreController: FeedbackCoreController,
        _ feedbackPostController: FeedbackPostController
    ) {
        self.orderCoreController = orderCoreController
        self.orderChecklistCoreController = orderChecklistCoreController
        self.orderMacroStatusCoreController = orderMacroStatusCoreController
        self.pickingProgressCoreController = pickingProgressCoreController
        self.trackingMiddleController = trackingMiddleController
        self.feedbackCoreController = feedbackCoreController
        self.feedbackPostController = feedbackPostController
    }
    
    
    // MARK: - Summaries
    
    
    public var orderSummaries: [OrderSummary] {
        
        orderCoreController.orderSummaries
    }
    
    
    public func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        orderCoreController.orderSummary(forOrderWithId: orderId)
    }
    
    
    public func loadOrderSummaries() async {
        
        await orderCoreController.loadOrderSummaries()
    }
    
    
    // MARK: - Details
    
    
    public var orderDetails: [OrderDetails] {
        
        orderCoreController.orderDetails
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderCoreController.orderDetails(forOrderWithId: orderId)
    }
    
    
    public func loadOrderDetails(forOrderWithId orderId: OrderSummary.ID) async {
        
        await orderCoreController.loadOrderDetails(forOrderWithId: orderId)
    }
    
    
    public func loadOrderDetailsIfMissing(forOrderWithId orderId: String) async {
        
        await orderCoreController.loadOrderDetailsIfMissing(forOrderWithId: orderId)
    }
    
    
    // MARK: - Items
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderCoreController.orderItems(forOrderWithId: orderId)
    }
    
    
    public func loadOrderItems(forOrderWithId orderId: OrderSummary.ID) async {
        
        await orderCoreController.loadOrderItems(forOrderWithId: orderId)
    }
    
    
    public func loadOrderItemsIfMissing(forOrderWithId orderId: String) async {
        
        await orderCoreController.loadOrderItemsIfMissing(forOrderWithId: orderId)
    }
    
    
    // MARK: - Update
    
    
    public func updateOrderStatus(orderId: OrderSummary.ID, status: OrderStatus) async {
        
        await orderCoreController.updateOrderStatus(orderId: orderId, status: status)
    }
    
    
    public func updateTrackingNo(forOrderWithId orderId: OrderSummary.ID, trackingNo: String) async {
        
        await orderCoreController.updateTrackingNo(forOrderWithId: orderId, trackingNo: trackingNo)
    }
    
    
    public func sendDriveThru(orderId: OrderSummary.ID) async {
        
        await orderCoreController.sendDriveThru(orderId: orderId)
    }
    
    
    // MARK: - Feedbacks
    
    
    public func orderFeedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        feedbackCoreController.feedbacks(forOrderWithId: orderId)
    }
    
    
    public func loadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackCoreController.loadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    public func loadOrderFeedbacksIfMissing(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackCoreController.loadOrderFeedbacksIfMissing(forOrderWithId: orderId)
    }
    
    
    // MARK: - Reload
    
    
    public func forceRefreshOrder(orderId: OrderSummary.ID) async {
        
        await loadOrderDetails(forOrderWithId: orderId)
        await loadOrderItems(forOrderWithId: orderId)
        await loadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
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
    
    
    // MARK: - Macro status
    
    
    public func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
        orderMacroStatusCoreController.macroStatus(forOrderWithId: orderId)
    }
    
    
    public func ordersMainListSections(restrictingToOrdersMatching searchText: String) -> [OrdersMainListSection] {
        
        let orders = orderSummaries.filter { $0.matches(searchText) }
        
        var sections: [OrdersMainListSection] = [
            
            .init(
                header: OrderMacroStatus.inTransitFor30PlusDays.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .inTransitFor30PlusDays }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.giveFeedback.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .giveFeedback }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.validatePayment.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .validatePayment }
                    .sorted { $0.date > $1.date }
            ),
            .init(
                header: OrderMacroStatus.pickAndPack.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .pickAndPack }
                    .sorted {
                        orderChecklistVerification($0.id) != orderChecklistVerification($1.id)
                        && orderChecklistVerification($0.id)
                        ||
                        orderChecklistVerification($0.id) != orderChecklistVerification($1.id)
                        && $0.lots < $1.lots
                    }
            ),
            .init(
                header: OrderMacroStatus.ship.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .ship }
                    .sorted { $0.date > $1.date }
            ),
            .init(
                header: OrderMacroStatus.received.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .received }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.inTransit.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .inTransit }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.recentlyClosed.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .recentlyClosed }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
        ]
        
        let closedOrders = orders
            .filter { macroStatus(forOrderWithId: $0.id) == .closed }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
        
        sections.append(contentsOf: closedOrders.grouppedByMonth.map { item in
            .init(
                header: "􀤟 \(item.month)",
                orders: item.elements
            )
        })
        
        return sections
    }
    
    
    public func reloadOrderSummaries() async {
        
        await orderCoreController.reloadOrderSummaries()
    }
    
    
    public func reloadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        await trackingMiddleController.reloadLaPosteTrackingStatus(forOrderWithId: orderId)
    }
    
    
    public func reloadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackCoreController.reloadOrderFeedbacks(forOrderWithId: orderId)
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
            .filter { macroStatus(forOrderWithId: $0.id).isOneOf(.inTransit, .inTransitFor30PlusDays, .received, .giveFeedback) }
        
        for order in ordersThatNeedRefreshFeedback {
            await reloadOrderFeedbacks(forOrderWithId: order.id)
        }
    }
    
    
    // MARK: - Checklist
    
    
    public func orderChecklistPayment(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistPayment(orderId)
    }
    
    
    public func orderChecklistIncomeTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistIncomeTransaction(orderId)
    }
    
    
    public func orderChecklistPicking(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistPicking(orderId)
    }
    
    
    public func orderChecklistVerification(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistVerification(orderId)
    }
    
    
    public func orderChecklistPacked(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistPacked(orderId)
    }
    
    
    public func orderChecklistStamping(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistStamping(orderId)
    }
    
    
    public func orderChecklistShippingTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistShippingTransaction(orderId)
    }
    
    
    public func orderChecklistTrackingNo(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistTrackingNo(orderId)
    }
    
    
    public func orderChecklistShipped(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistShipped(orderId)
    }
    
        
    public func orderChecklistDriveThru(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistDriveThru(orderId)
    }
    
    
    public func orderChecklistReceived(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistReceived(orderId)
    }
    
    
    public func orderChecklistCompleted(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistCompleted(orderId)
    }
    
    
    public func orderChecklistBuyerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistBuyerFeedback(orderId)
    }
    
    
    public func orderChecklistSellerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistSellerFeedback(orderId)
    }
    
    
    public func orderChecklistUnchangedFor30Days(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistUnchangedFor30Days(orderId)
    }
    
    
    public func pickingProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        pickingProgressCoreController.pickingProgress(forOrderWithId: orderId)
    }
    
    
    public func pickingVerificationProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        pickingProgressCoreController.pickingVerificationProgress(forOrderWithId: orderId)
    }
    
    
    public func laPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(forOrderWithId: orderId)
    }
    
    
    public func checklist(forOrderWithId orderId: OrderSummary.ID) -> Checklist {
        
        Checklist(sections: [
            .init(
                title: OrderMacroStatus.validatePayment.descriptionWithPicto,
                items: [
                    .init(
                        label: "Payment received",
                        checked: orderChecklistPayment(orderId)
                    ),
                    .init(
                        label: "Register transaction",
                        checked: orderChecklistIncomeTransaction(orderId)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.pickAndPack.descriptionWithPicto,
                items: [
                    .init(
                        label: {
                            let progress = pickingProgress(forOrderWithId: orderId)
                            if progress == 0% || progress == 100% {
                                return  "Pick items"
                            } else {
                                return "Pick items - \(progress) complete"
                            }
                        }(),
                        checked: orderChecklistPicking(orderId)
                    ),
                    .init(
                        label: {
                            let progress = pickingProgressCoreController.pickingVerificationProgress(forOrderWithId: orderId)
                            if progress == 0% || progress == 100% {
                                return "Verify items"
                            } else {
                                return "Verify items - \(progress) complete"
                            }
                        }(),
                        checked: orderChecklistVerification(orderId)
                    ),
                    .init(
                        label: "Pack order",
                        checked: orderChecklistPacked(orderId)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.ship.descriptionWithPicto,
                items: [
                    .init(
                        label: "Validate stamping",
                        checked: orderChecklistStamping(orderId)
                    ),
                    .init(
                        label: "Register transaction",
                        checked: orderChecklistShippingTransaction(orderId)
                    ),
                    .init(
                        label: "Input tracking no",
                        checked: orderChecklistTrackingNo(orderId)
                    ),
                    .init(
                        label: "Mark Shipped",
                        checked: orderChecklistShipped(orderId)
                    ),
                    .init(
                        label: "Send drive thru",
                        checked: orderChecklistDriveThru(orderId)
                    ),
                ]
            ),
            .init(
                title: "􀐚 Shipped",
                items: [
                    .init(
                        label: "Picked up by transporter",
                        checked: laPosteTrackingStatus(forOrderWithId: orderId)?.isOneOf(.inTransit, .delivered) ?? false,
                        mandatory: false
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.inTransit.descriptionWithPicto,
                items: [
                    .init(
                        label: "Received",
                        checked: orderChecklistReceived(orderId)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.received.descriptionWithPicto,
                items: [
                    .init(
                        label: "Completed",
                        checked: orderChecklistCompleted(orderId)
                    ),
                    .init(
                        label: "Buyer feedback",
                        checked: orderChecklistBuyerFeedback(orderId)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.giveFeedback.descriptionWithPicto,
                items: [
                    .init(
                        label: "Give feedback",
                        checked: orderChecklistSellerFeedback(orderId)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.closed.descriptionWithPicto,
                items: []
            ),
        ])
    }
    
    
    // MARK: - Actions
    
    
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
    
    
    public func postPraiseOrderFeedback(orderId: OrderSummary.ID) async {
        
        await feedbackPostController.postPraiseFeedback(forOrderWithId: orderId)
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
    
    
    // MARK: - Sidebar
    
    
    public var numberForSidebarBadge: Int {
        
        orderSummaries.filter {
            macroStatus(forOrderWithId: $0.id).isOneOf(
                .ship, .pickAndPack, .validatePayment, .giveFeedback, .inTransitFor30PlusDays
            )
        }.count
    }
}



struct Checklist {
    
    let sections: [Section]
    
    struct Section: Identifiable {
        
        var id: String { title }
        let title: String
        let items: [Item]
    }
    
    struct Item: Identifiable {
        
        var id: String { label }
        let label: String
        let checked: Bool
        let mandatory: Bool
        
        init(label: String, checked: Bool, mandatory: Bool = true) {
            self.label = label
            self.checked = checked
            self.mandatory = mandatory
        }
    }
}
