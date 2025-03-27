
import Foundation



@Observable
@MainActor
public class OrderStore {
    
    
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
    
    
    // MARK: - URLs
    
    
    public func url(forDetailsOf order: Order) -> URL? {
        
        BrickLinkUtility.url(forDetailsOfOrderWithId: order.id)
    }
    
    
    // MARK: - Orders
    
    
    public var orders: [Order] {
        
        orderCoreController.orders
    }
    
    
    public func order(withId orderId: Order.ID) -> Order? {
        
        orderCoreController.order(withId: orderId)
    }
    
    
    public func loadOrders() async {
        
        await orderCoreController.loadOrders()
    }
    
    
    // MARK: - Details
    
    
    public func details(for order: Order) -> OrderDetails? {
        
        orderCoreController.details(for: order)
    }
    
    
    public func loadDetails(for order: Order) async {
        
        await orderCoreController.loadDetails(for: order)
    }
    
    
    public func loadDetailsIfMissing(for order: Order) async {
        
        await orderCoreController.loadDetailsIfMissing(for: order)
    }
    
    
    // MARK: - Items
    
    
    public func items(for order: Order) -> [OrderItem] {
        
        orderCoreController.items(for: order)
    }
    
    
    public func loadItems(for order: Order) async {
        
        await orderCoreController.loadItems(for: order)
    }
    
    
    public func loadItemsIfMissing(for order: Order) async {
        
        await orderCoreController.loadItemsIfMissing(for: order)
    }
    
    
    // MARK: - Update
    
    
    public func updateStatus(of order: Order, to status: OrderStatus) async {
        
        await orderCoreController.updateStatus(of: order, to: status)
    }
    
    
    public func updateTrackingNo(of order: Order, to trackingNo: String) async {
        
        await orderCoreController.updateTrackingNo(of: order, to: trackingNo)
    }
    
    
    public func sendDriveThru(for order: Order) async {
        
        await orderCoreController.sendDriveThru(for: order)
    }
    
    
    // MARK: - Feedbacks
    
    
    public func orderFeedbacks(for order: Order) -> [Feedback] {
        
        feedbackCoreController.feedbacks(for: order)
    }
    
    
    public func loadOrderFeedbacks(for order: Order) async {
        
        await feedbackCoreController.loadOrderFeedbacks(for: order)
    }
    
    
    public func loadOrderFeedbacksIfMissing(for order: Order) async {
        
        await feedbackCoreController.loadOrderFeedbacksIfMissing(for: order)
    }
    
    
    // MARK: - Reload
    
    
    public func forceRefreshOrder(_ order: Order) async {
        
        await loadDetails(for: order)
        await loadItems(for: order)
        await loadOrderFeedbacks(for: order)
    }
    
    
    public func loadMissingOrders() async {
        
        for order in orders {
            
            await loadDetailsIfMissing(for: order)
            await loadItemsIfMissing(for: order)
            await loadOrderFeedbacksIfMissing(for: order)
        }
    }
    
    
    public func refreshAllOrders() async {
        
        for order in orders {
            
            await refreshOrder(order)
        }
    }
    
    
    public func refreshOrder(_ order: Order) async {
        
        if shouldRefreshOrder(order) {
            
            await loadDetails(for: order)
            await loadItems(for: order)
            await loadOrderFeedbacks(for: order)
        }
    }
    
    
    public func orderIsClosedForMoreThan30Days(_ order: Order) -> Bool {
        
        return (
            order.status.isOneOf(.completed, .cancelled, .purged)
            &&
            order.dateStatusChanged.days(to: Date()) > 30
        )
    }
    
    
    public func shouldRefreshOrder(_ order: Order) -> Bool {
        
        if orderIsClosedForMoreThan30Days(order) {
            
            guard
                let orderDetails = details(for: order)
            else {
                return true
            }
            
            let orderItems = items(for: order)
            if orderItems.isEmpty {
                
                return true
            }
            
            if orderDetails.differs(from: order) {
                
                return true
            }
            
            let feedbacks = orderFeedbacks(for: order)
            if !feedbacks.hasSellerFeedback() {
                
                return true
            }
            
            return false
            
        } else {
        
            return true
        }
    }
    
    
    // MARK: - Macro status
    
    
    public func macroStatus(for order: Order) -> OrderMacroStatus {
        
        orderMacroStatusCoreController.macroStatus(for: order)
    }
    
    
    public func ordersMainListSections(restrictingToOrdersMatching searchText: String) -> [OrdersMainListSection] {
        
        let orders = orders.filter { $0.matches(searchText) }
        
        var sections: [OrdersMainListSection] = [
            
            .init(
                header: OrderMacroStatus.inTransitFor30PlusDays.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(for: $0) == .inTransitFor30PlusDays }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.giveFeedback.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(for: $0) == .giveFeedback }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.validatePayment.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(for: $0) == .validatePayment }
                    .sorted { $0.date > $1.date }
            ),
            .init(
                header: OrderMacroStatus.pickAndPack.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(for: $0) == .pickAndPack }
                    .sorted {
                        orderChecklistVerification($0) != orderChecklistVerification($1)
                        && orderChecklistVerification($0)
                        ||
                        orderChecklistVerification($0) != orderChecklistVerification($1)
                        && $0.lots < $1.lots
                    }
            ),
            .init(
                header: OrderMacroStatus.ship.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(for: $0) == .ship }
                    .sorted { $0.date > $1.date }
            ),
            .init(
                header: OrderMacroStatus.received.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(for: $0) == .received }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.inTransit.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(for: $0) == .inTransit }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.recentlyClosed.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(for: $0) == .recentlyClosed }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
        ]
        
        let closedOrders = orders
            .filter { macroStatus(for: $0) == .closed }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
        
        sections.append(contentsOf: closedOrders.grouppedByMonth.map { item in
            .init(
                header: "􀤟 \(item.month)",
                orders: item.elements
            )
        })
        
        return sections
    }
    
    
    public func reloadOrders() async {
        
        await orderCoreController.reloadOrders()
    }
    
    
    public func reloadLaPosteTrackingStatus(for order: Order) async {
        
        await trackingMiddleController.reloadLaPosteTrackingStatus(for: order)
    }
    
    
    public func reloadOrderFeedbacks(for order: Order) async {
        
        await feedbackCoreController.reloadOrderFeedbacks(for: order)
    }
    
    
    public func refreshOrdersMainList() async {
        
        await reloadOrders()
        
        let allOrders = orders
        
        let ordersThatNeedRefreshLaPosteTrackingStatus = allOrders
            .filter { macroStatus(for: $0) == .inTransit }
        
        for order in ordersThatNeedRefreshLaPosteTrackingStatus {
            await reloadLaPosteTrackingStatus(for: order)
        }
        
        let ordersThatNeedRefreshFeedback = allOrders
            .filter { macroStatus(for: $0).isOneOf(.inTransit, .inTransitFor30PlusDays, .received, .giveFeedback) }
        
        for order in ordersThatNeedRefreshFeedback {
            await reloadOrderFeedbacks(for: order)
        }
    }
    
    
    // MARK: - Checklist
    
    
    public func orderChecklistPayment(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistPayment(order)
    }
    
    
    public func orderChecklistIncomeTransaction(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistIncomeTransaction(order)
    }
    
    
    public func orderChecklistPicking(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistPicking(order)
    }
    
    
    public func orderChecklistVerification(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistVerification(order)
    }
    
    
    public func orderChecklistPacked(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistPacked(order)
    }
    
    
    public func orderChecklistStamping(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistStamping(order)
    }
    
    
    public func orderChecklistShippingTransaction(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistShippingTransaction(order)
    }
    
    
    public func orderChecklistTrackingNo(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistTrackingNo(order)
    }
    
    
    public func orderChecklistShipped(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistShipped(order)
    }
    
        
    public func orderChecklistDriveThru(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistDriveThru(order)
    }
    
    
    public func orderChecklistReceived(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistReceived(order)
    }
    
    
    public func orderChecklistCompleted(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistCompleted(order)
    }
    
    
    public func orderChecklistBuyerFeedback(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistBuyerFeedback(order)
    }
    
    
    public func orderChecklistSellerFeedback(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistSellerFeedback(order)
    }
    
    
    public func orderChecklistUnchangedFor30Days(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistUnchangedFor30Days(order )
    }
    
    
    public func pickingProgress(for order: Order) -> Percent {
        
        pickingProgressCoreController.pickingProgress(for: order)
    }
    
    
    public func pickingVerificationProgress(for order: Order) -> Percent {
        
        pickingProgressCoreController.pickingVerificationProgress(for: order)
    }
    
    
    public func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(for: order)
    }
    
    
    public func checklist(for order: Order) -> Checklist {
        
        Checklist(sections: [
            .init(
                title: OrderMacroStatus.validatePayment.descriptionWithPicto,
                items: [
                    .init(
                        label: "Payment received",
                        checked: orderChecklistPayment(order)
                    ),
                    .init(
                        label: "Register transaction",
                        checked: orderChecklistIncomeTransaction(order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.pickAndPack.descriptionWithPicto,
                items: [
                    .init(
                        label: {
                            let progress = pickingProgress(for: order)
                            if progress == 0% || progress == 100% {
                                return  "Pick items"
                            } else {
                                return "Pick items - \(progress) complete"
                            }
                        }(),
                        checked: orderChecklistPicking(order)
                    ),
                    .init(
                        label: {
                            let progress = pickingProgressCoreController.pickingVerificationProgress(for: order)
                            if progress == 0% || progress == 100% {
                                return "Verify items"
                            } else {
                                return "Verify items - \(progress) complete"
                            }
                        }(),
                        checked: orderChecklistVerification(order)
                    ),
                    .init(
                        label: "Pack order",
                        checked: orderChecklistPacked(order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.ship.descriptionWithPicto,
                items: [
                    .init(
                        label: "Validate stamping",
                        checked: orderChecklistStamping(order)
                    ),
                    .init(
                        label: "Register transaction",
                        checked: orderChecklistShippingTransaction(order)
                    ),
                    .init(
                        label: "Input tracking no",
                        checked: orderChecklistTrackingNo(order)
                    ),
                    .init(
                        label: "Mark Shipped",
                        checked: orderChecklistShipped(order)
                    ),
                    .init(
                        label: "Send drive thru",
                        checked: orderChecklistDriveThru(order)
                    ),
                ]
            ),
            .init(
                title: "􀐚 Shipped",
                items: [
                    .init(
                        label: "Picked up by transporter",
                        checked: laPosteTrackingStatus(for: order)?.isOneOf(.inTransit, .delivered) ?? false,
                        mandatory: false
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.inTransit.descriptionWithPicto,
                items: [
                    .init(
                        label: "Received",
                        checked: orderChecklistReceived(order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.received.descriptionWithPicto,
                items: [
                    .init(
                        label: "Completed",
                        checked: orderChecklistCompleted(order)
                    ),
                    .init(
                        label: "Buyer feedback",
                        checked: orderChecklistBuyerFeedback(order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.giveFeedback.descriptionWithPicto,
                items: [
                    .init(
                        label: "Give feedback",
                        checked: orderChecklistSellerFeedback(order)
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
    
    
    public var ordersThatNeedCompletedAndGiveFeedback: [Order] {
        
        orders
            .filter { macroStatus(for: $0) == .inTransitFor30PlusDays }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
    }
    
    
    public var ordersThatNeedGiveFeedback: [Order] {
        
        orders
            .filter { macroStatus(for: $0) == .giveFeedback }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
    }
    
    
    public var ordersToShipAndSendDriveThru: [Order] {
        
        orders
            .filter {
                macroStatus(for: $0) == .ship
                && orderChecklistStamping($0)
                && orderChecklistShippingTransaction($0)
                && orderChecklistTrackingNo($0)
            }
            .sorted { $0.date > $1.date }
    }
    
    
    public var ordersThatNeedAction: [Order] {
        
        ordersThatNeedCompletedAndGiveFeedback
        + ordersThatNeedGiveFeedback
        + ordersToShipAndSendDriveThru
    }
    
    
    public func postPraiseOrderFeedback(for order: Order) async {
        
        await feedbackPostController.postPraiseFeedback(for: order)
    }
    
    
    public func performActionForAllOrders() async {
        
        for order in ordersThatNeedCompletedAndGiveFeedback {
        
            await updateStatus(of: order, to: .completed)
            await postPraiseOrderFeedback(for: order)
        }
        
        for order in ordersThatNeedGiveFeedback {
            
            await postPraiseOrderFeedback(for: order)
        }
        
        for order in ordersToShipAndSendDriveThru {
            
            await updateStatus(of: order, to: .shipped)
            await sendDriveThru(for: order)
        }
    }
    
    
    // MARK: - Sidebar
    
    
    public var numberForSidebarBadge: Int {
        
        orders.filter {
            macroStatus(for: $0).isOneOf(
                .ship, .pickAndPack, .validatePayment, .giveFeedback, .inTransitFor30PlusDays
            )
        }.count
    }
}



public struct Checklist {
    
    public let sections: [Section]
    
    public struct Section: Identifiable {
        
        public var id: String { title }
        public let title: String
        public let items: [Item]
    }
    
    public struct Item: Identifiable {
        
        public var id: String { label }
        public let label: String
        public let checked: Bool
        public let mandatory: Bool
        
        public init(label: String, checked: Bool, mandatory: Bool = true) {
            self.label = label
            self.checked = checked
            self.mandatory = mandatory
        }
    }
}
