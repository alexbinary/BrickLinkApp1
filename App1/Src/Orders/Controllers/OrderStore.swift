import Foundation



@MainActor
protocol OrderStoreProtocol {
    
    
    func url(forDetailsOf order: Order) -> URL?
    
    var orders: [Order]  { get }
    func order(withId orderId: Order.ID) -> Order?
    func details(for order: Order) -> OrderDetails?
    func isLoadingDetails(for order: Order) -> Bool
    
    func updateStatus(of order: Order, to status: OrderStatus) async
    func isUpdatingStatus(of order: Order, to status: OrderStatus) -> Bool
    func updateTrackingNo(of order: Order, to trackingNo: TrackingNo) async
    func isUpdatingTrackingNo(of order: Order) -> Bool
    func sendDriveThru(for order: Order) async
    func isSendingDriveThru(for order: Order) -> Bool
    
    func state(of item: ChecklistItem, for order: Order) -> ChecklistState
    func order(_ order: Order, validates item: ChecklistItem) -> Bool
    func checklistData(for order: Order) -> ChecklistData
    func macroStatus(for order: Order) -> OrderMacroStatus
    func ordersMainListSections(restrictingToOrdersMatching searchText: String) -> [OrdersMainListSection]

    func softRefreshOrders() async
    func hardRefreshOrders(_ operationTag: OperationTag?) async
    func hardRefresh(orderWithId orderId: Order.ID, _ operationTag: OperationTag?) async
    func hardRefreshDetails(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag?) async
    func softRefreshItems(for order: Order) async
    func hardRefreshItems(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag?) async

    func ordersThatNeedCompletedAndGiveFeedback(_ orders: [Order]) -> [Order]
    func ordersThatNeedGiveFeedback(_ orders: [Order]) -> [Order]
    func ordersToShipAndSendDriveThru(_ orders: [Order]) -> [Order]
    func ordersThatNeedAction(_ orders: [Order]) -> [Order]
    func performActions(for orders: [Order]) async
    
    var numberForSidebarBadge: Int { get }
}



@Observable
@MainActor
class OrderStore: OrderStoreProtocol {
    
    
    private let orderController: OrderController
    private let checklistController: ChecklistController
    private let macroStatusController: MacroStatusController
    private let pickingProgressController: PickingProgressController
    private let trackingMiddleController: TrackingMiddleController
    private let feedbackController: FeedbackController
    private let feedbackPostController: FeedbackPostController
    
    
    init(
        _ orderController: OrderController,
        _ checklistController: ChecklistController,
        _ macroStatusController: MacroStatusController,
        _ pickingProgressController: PickingProgressController,
        _ trackingMiddleController: TrackingMiddleController,
        _ feedbackController: FeedbackController,
        _ feedbackPostController: FeedbackPostController
    ) {
        self.orderController = orderController
        self.checklistController = checklistController
        self.macroStatusController = macroStatusController
        self.pickingProgressController = pickingProgressController
        self.trackingMiddleController = trackingMiddleController
        self.feedbackController = feedbackController
        self.feedbackPostController = feedbackPostController
    }
    
    
    // MARK: - URLs
    
    
    func url(forDetailsOf order: Order) -> URL? {
        
        BrickLinkUtility.url(forDetailsOfOrderWithId: order.id)
    }
    
    
    // MARK: - Orders
    
    
    var orders: [Order] {
        
        orderController.orders
    }
    
    
    func order(withId orderId: Order.ID) -> Order? {
        
        orderController.order(withId: orderId)
    }
    
    
    private func loadOrders(_ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await orderController.loadOrders(refetchStrategy, operationTag)
    }
    
    
    // MARK: - Details
    
    
    private func hasDetails(for order: Order) -> Bool {
        
        orderController.hasDetails(for: order)
    }
    
    
    func details(for order: Order) -> OrderDetails? {
        
        orderController.details(for: order)
    }
    
    
    private func loadDetails(for order: Order, _ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await orderController.loadDetails(for: order, refetchStrategy, operationTag)
    }
    
    
    func isLoadingDetails(for order: Order) -> Bool {
        
        orderController.isLoadingDetails(for: order)
    }
    
    
    // MARK: - Items
    
    
    private func hasItems(for order: Order) -> Bool {
        
        orderController.hasItems(for: order)
    }
    
    
    private func loadItems(for order: Order, _ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await orderController.loadItems(for: order, refetchStrategy, operationTag)
    }
    
    
    // MARK: - Update
    
    
    func updateStatus(of order: Order, to status: OrderStatus) async {
        
        await orderController.updateStatus(of: order, to: status)
    }
    
    
    func isUpdatingStatus(of order: Order, to status: OrderStatus) -> Bool {
        
        orderController.isUpdatingStatus(of: order, to: status)
    }
    
    
    func updateTrackingNo(of order: Order, to trackingNo: TrackingNo) async {
        
        await orderController.updateTrackingNo(of: order, to: trackingNo)
    }
    
    
    func isUpdatingTrackingNo(of order: Order) -> Bool {
        
        orderController.isUpdatingTrackingNo(of: order)
    }
    
    
    func sendDriveThru(for order: Order) async {
        
        await orderController.sendDriveThru(for: order)
    }
    
    
    func isSendingDriveThru(for order: Order) -> Bool {
        
        orderController.isSendingDriveThru(for: order)
    }
    
    
    // MARK: - Checklist
    
    
    func state(of item: ChecklistItem, for order: Order) -> ChecklistState {
        
        checklistController.state(of: item, for: order)
    }
    
    
    func order(_ order: Order, validates item: ChecklistItem) -> Bool {
        
        checklistController.order(order, validates: item)
    }
    
    
    private func pickingProgress(for order: Order) -> Percent {
        
        pickingProgressController.pickingProgress(for: order)
    }
    
    
    private func pickingVerificationProgress(for order: Order) -> Percent {
        
        pickingProgressController.pickingVerificationProgress(for: order)
    }
    
    
    private func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(for: order)
    }
    
    
    func checklistData(for order: Order) -> ChecklistData {
        
        return ChecklistData(sections: [
            .init(
                title: OrderMacroStatus.validatePayment.descriptionWithPicto,
                items: [
                    .init(
                        label: "Payment received",
                        state: state(of: .payment, for: order)
                    ),
                    .init(
                        label: "Register transaction",
                        state: state(of: .incomeTransaction, for: order)
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
                        state: state(of: .picking, for: order)
                    ),
                    .init(
                        label: {
                            let progress = pickingVerificationProgress(for: order)
                            if progress == 0% || progress == 100% {
                                return "Verify items"
                            } else {
                                return "Verify items - \(progress) complete"
                            }
                        }(),
                        state: state(of: .verification, for: order)
                    ),
                    .init(
                        label: "Pack order",
                        state: state(of: .packed, for: order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.ship.descriptionWithPicto,
                items: [
                    .init(
                        label: "Validate stamping",
                        state: state(of: .stamping, for: order)
                    ),
                    .init(
                        label: "Register transaction",
                        state: state(of: .shippingTransaction, for: order)
                    ),
                    .init(
                        label: "Input tracking no",
                        state: state(of: .trackingNo, for: order)
                    ),
                    .init(
                        label: "Mark Shipped",
                        state: state(of: .shipped, for: order)
                    ),
                    .init(
                        label: "Send drive thru",
                        state: state(of: .driveThru, for: order)
                    ),
                ]
            ),
            .init(
                title: "􀐚 Shipped",
                items: [
                    .init(
                        label: "Picked up by transporter",
                        state: laPosteTrackingStatus(for: order)?.isOneOf(.inTransit, .delivered) ?? false ? .validated : .pending,
                        mandatory: false
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.inTransit.descriptionWithPicto,
                items: [
                    .init(
                        label: "Received",
                        state: state(of: .received, for: order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.received.descriptionWithPicto,
                items: [
                    .init(
                        label: "Completed",
                        state: state(of: .completed, for: order)
                    ),
                    .init(
                        label: "Buyer feedback",
                        state: state(of: .buyerFeedback, for: order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.giveFeedback.descriptionWithPicto,
                items: [
                    .init(
                        label: "Give feedback",
                        state: state(of: .sellerFeedback, for: order)
                    ),
                ]
            )
        ])
    }


    // MARK: - Macro status
    
    
    func macroStatus(for order: Order) -> OrderMacroStatus {
        
        macroStatusController.macroStatus(for: order)
    }
    
    
    func ordersMainListSections(restrictingToOrdersMatching searchText: String) -> [OrdersMainListSection] {
        
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
                        self.order($0, validates: .verification) != self.order($1, validates: .verification)
                        && self.order($0, validates: .verification)
                        ||
                        self.order($0, validates: .verification) != self.order($1, validates: .verification)
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
    
    
    // MARK: - Refresh
    
    
    private func loadLaPosteTrackingStatus(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await trackingMiddleController.loadLaPosteTrackingStatus(for: order, refetchStrategy, operationTag)
    }
    
    
    private func loadFeedbacks(for order: Order, _ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await feedbackController.loadFeedbacks(for: order, refetchStrategy, operationTag)
    }
    
    
    private func orderIsClosedForMoreThan30Days(_ order: Order) -> Bool {
        
        return (
            order.status.isOneOf(.completed, .cancelled, .purged)
            &&
            order.dateStatusChanged.days(to: Date()) > 30
        )
    }
    
    
    private func orderNeedsRefreshLaPosteTrackingStatus(_ order: Order) -> Bool {
        
        macroStatus(for: order) == .inTransit
    }
    
    
    private func orderNeedsRefreshFeedback(_ order: Order) -> Bool {
        
        macroStatus(for: order).isOneOf(.inTransit, .inTransitFor30PlusDays, .received, .giveFeedback)
    }
    
    
    private func refreshOrders(_ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await loadOrders(refetchStrategy, operationTag)
        
        await withTaskGroup { group in
            
            for order in orders {
                group.addTask {
                    
                    if !(await self.hasDetails(for: order)) {
                        await self.loadDetails(for: order, .forceRefetch, operationTag)
                    }
                    if !(await self.orderIsClosedForMoreThan30Days(order)) && refetchStrategy == .forceRefetch {
                        await self.loadDetails(for: order, .forceRefetch, operationTag)
                    }
                    if await self.orderNeedsRefreshLaPosteTrackingStatus(order) {
                        Task { await self.loadLaPosteTrackingStatus(for: order, refetchStrategy, operationTag) }
                    }
                    if await self.orderNeedsRefreshFeedback(order) {
                        Task { await self.loadFeedbacks(for: order, refetchStrategy, operationTag) }
                    }
                }
            }
        }
    }
    
    
    func softRefreshOrders() async {
        
        await refreshOrders(.refetchOnlyIfInvalidated)
    }
    
    
    func hardRefreshOrders(_ operationTag: OperationTag? = nil) async {
        
        await refreshOrders(.forceRefetch, operationTag)
    }
    
    
    private func refresh(_ order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await loadOrders(refetchStrategy, operationTag)
    }
    
    
    private func softRefresh(_ order: Order, _ operationTag: OperationTag? = nil) async {
        
        await refresh(order, .refetchOnlyIfInvalidated, operationTag)
    }
    
    
    private func softRefresh(orderWithId orderId: Order.ID) async {
        
        await softRefresh(order(withId: orderId)!)
    }
    
    
    private func hardRefresh(_ order: Order, _ operationTag: OperationTag? = nil) async {
        
        await refresh(order, .forceRefetch, operationTag)
    }
    
    
    func hardRefresh(orderWithId orderId: Order.ID, _ operationTag: OperationTag? = nil) async {
        
        await hardRefresh(order(withId: orderId)!, operationTag)
    }
    
    
    private func refreshDetails(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        let strategy = hasDetails(for: order) ? refetchStrategy : .forceRefetch
        
        await loadDetails(for: order, strategy, operationTag)
    }
    
    
    private func softRefreshDetails(for order: Order) async {
        
        await refreshDetails(for: order, .refetchOnlyIfInvalidated)
    }


    private func softRefreshDetails(forOrderWithId orderId: Order.ID) async {
        
        await softRefreshDetails(for: order(withId: orderId)!)
    }
    
    
    private func hardRefreshDetails(for order: Order, _ operationTag: OperationTag? = nil) async {
        
        await refreshDetails(for: order, .forceRefetch, operationTag)
    }


    func hardRefreshDetails(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag? = nil) async {
        
        await hardRefreshDetails(for: order(withId: orderId)!, operationTag)
    }
    
    
    private func refreshItems(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        let strategy = hasItems(for: order) ? refetchStrategy : .forceRefetch
        
        await loadItems(for: order, strategy, operationTag)
    }
    
    
    func softRefreshItems(for order: Order) async {
        
        await refreshItems(for: order, .refetchOnlyIfInvalidated)
    }
    
    
    private func softRefreshItems(forOrderWithId orderId: Order.ID) async {
        
        await softRefreshItems(for: order(withId: orderId)!)
    }
    
    
    private func hardRefreshItems(for order: Order, _ operationTag: OperationTag? = nil) async {
        
        await refreshItems(for: order, .forceRefetch, operationTag)
    }
    
    
    func hardRefreshItems(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag? = nil) async {
        
        await hardRefreshItems(for: order(withId: orderId)!, operationTag)
    }
    
    
    // MARK: - Actions
    
    
    private func orderNeedsCompletedAndGiveFeedback(_ order: Order) -> Bool {
        
        macroStatus(for: order) == .inTransitFor30PlusDays
    }
    
    
    func ordersThatNeedCompletedAndGiveFeedback(_ orders: [Order]) -> [Order] {
        
        orders.filter { orderNeedsCompletedAndGiveFeedback($0) }
              .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
    }
    
    
    private func orderNeedsGiveFeedback(_ order: Order) -> Bool {
        
        macroStatus(for: order) == .giveFeedback
    }
    
    
    func ordersThatNeedGiveFeedback(_ orders: [Order]) -> [Order] {
        
        orders.filter { orderNeedsGiveFeedback($0) }
              .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
    }
    
    
    private func orderNeedsShipAndSendDriveThru(_ order: Order) -> Bool {
        
        macroStatus(for: order) == .ship
        && self.order(order, validates: .stamping)
        && self.order(order, validates: .shippingTransaction)
        && self.order(order, validates: .trackingNo)
    }
    
    
    func ordersToShipAndSendDriveThru(_ orders: [Order]) -> [Order] {
        
        orders.filter { orderNeedsShipAndSendDriveThru($0) }
              .sorted { $0.date > $1.date }
    }
    
    
    private func orderNeedsAction(_ order: Order) -> Bool {
        
        orderNeedsCompletedAndGiveFeedback(order)
        ||
        orderNeedsGiveFeedback(order)
        ||
        orderNeedsShipAndSendDriveThru(order)
    }
    
    
    func ordersThatNeedAction(_ orders: [Order]) -> [Order] {
        
        ordersThatNeedCompletedAndGiveFeedback(orders)
        + ordersThatNeedGiveFeedback(orders)
        + ordersToShipAndSendDriveThru(orders)
    }
    
    
    private func postPraiseOrderFeedback(for order: Order) async {
        
        await feedbackPostController.postPraiseFeedback(for: order)
    }
    
    
    func performActions(for orders: [Order]) async {
        
        for order in ordersThatNeedCompletedAndGiveFeedback(orders) {
        
            await updateStatus(of: order, to: .completed)
            await postPraiseOrderFeedback(for: order)
        }
        
        for order in ordersThatNeedGiveFeedback(orders) {
            
            await postPraiseOrderFeedback(for: order)
        }
        
        for order in ordersToShipAndSendDriveThru(orders) {
            
            await updateStatus(of: order, to: .shipped)
            await sendDriveThru(for: order)
        }
    }
    
    
    // MARK: - Sidebar
    
    
    var numberForSidebarBadge: Int {
        
        orders.filter {
            macroStatus(for: $0).isOneOf(
                .ship, .pickAndPack, .validatePayment, .giveFeedback, .inTransitFor30PlusDays
            )
        }.count
    }
}



struct ChecklistData: Equatable {
    
    let sections: [SectionData]
    
    struct SectionData: Identifiable, Equatable {
        
        var id: String { title }
        let title: String
        let items: [ItemData]
    }
    
    struct ItemData: Identifiable, Equatable {
        
        var id: String { label }
        let label: String
        let state: ChecklistState
        let mandatory: Bool
        
        init(label: String, state: ChecklistState, mandatory: Bool = true) {
            self.label = label
            self.state = state
            self.mandatory = mandatory
        }
    }
}
