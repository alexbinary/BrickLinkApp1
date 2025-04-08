import Foundation



@Observable
@MainActor
public class OrderStore {
    
    
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
    
    
    public func url(forDetailsOf order: Order) -> URL? {
        
        BrickLinkUtility.url(forDetailsOfOrderWithId: order.id)
    }
    
    
    // MARK: - Orders
    
    
    public var orders: [Order] {
        
        orderController.orders
    }
    
    
    public func order(withId orderId: Order.ID) -> Order? {
        
        orderController.order(withId: orderId)
    }
    
    
    public func loadOrders(_ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await orderController.loadOrders(refetchStrategy, operationTag)
    }
    
    
    public var isLoadingOrders: Bool {
     
        orderController.isLoadingOrders
    }
    
    
    // MARK: - Details
    
    
    public func hasDetails(for order: Order) -> Bool {
        
        orderController.hasDetails(for: order)
    }
    
    
    public func details(for order: Order) -> OrderDetails? {
        
        orderController.details(for: order)
    }
    
    
    public func loadDetails(for order: Order, _ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await orderController.loadDetails(for: order, refetchStrategy, operationTag)
    }
    
    
    public var isLoadingOrderDetails: Bool {
        
        orderController.isLoadingOrderDetails
    }
    
    
    public func isLoadingDetails(for order: Order) -> Bool {
        
        orderController.isLoadingDetails(for: order)
    }
    
    
    // MARK: - Items
    
    
    public func hasItems(for order: Order) -> Bool {
        
        orderController.hasItems(for: order)
    }
    
    
    public func items(for order: Order) -> [OrderItem] {
        
        orderController.items(for: order)
    }
    
    
    public func loadItems(for order: Order, _ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await orderController.loadItems(for: order, refetchStrategy, operationTag)
    }
    
    
    public func loadItemsIfMissing(for order: Order) async {
        
        await orderController.loadItemsIfMissing(for: order)
    }
    
    
    public var isLoadingOrderItems: Bool {
        
        orderController.isLoadingOrderItems
    }
    
    
    public func isLoadingItems(for order: Order) -> Bool {
        
        orderController.isLoadingItems(for: order)
    }
    
    
    // MARK: - Update
    
    
    public func updateStatus(of order: Order, to status: OrderStatus) async {
        
        await orderController.updateStatus(of: order, to: status)
    }
    
    
    public var isUpdatingOrderStatus: Bool {
        
        orderController.isUpdatingOrderStatus
    }
    
    
    public func isUpdatingStatus(of order: Order) -> Bool {
        
        orderController.isUpdatingStatus(of: order)
    }
    
    
    public func isUpdatingStatus(of order: Order, to status: OrderStatus) -> Bool {
        
        orderController.isUpdatingStatus(of: order, to: status)
    }
    
    
    public func updateTrackingNo(of order: Order, to trackingNo: TrackingNo) async {
        
        await orderController.updateTrackingNo(of: order, to: trackingNo)
    }
    
    
    public var isUpdatingOrderTrackingNo: Bool {
        
        orderController.isUpdatingOrderTrackingNo
    }
    
    
    public func isUpdatingTrackingNo(of order: Order) -> Bool {
        
        orderController.isUpdatingTrackingNo(of: order)
    }
    
    
    public func sendDriveThru(for order: Order) async {
        
        await orderController.sendDriveThru(for: order)
    }
    
    
    public var isSendingDriveThru: Bool {
        
        orderController.isSendingDriveThru
    }
    
    
    public func isSendingDriveThru(for order: Order) -> Bool {
        
        orderController.isSendingDriveThru(for: order)
    }
    
    
    // MARK: - Checklist
    
    
    public func checklist_payment(_ order: Order) -> Bool {
        
        checklistController.checklist_payment(order)
    }
    
    
    public func checklist_incomeTransaction(_ order: Order) -> Bool {
        
        checklistController.checklist_incomeTransaction(order)
    }
    
    
    public func checklist_picking(_ order: Order) -> Bool {
        
        checklistController.checklist_picking(order)
    }
    
    
    public func checklist_verification(_ order: Order) -> Bool {
        
        checklistController.checklist_verification(order)
    }
    
    
    public func checklist_packed(_ order: Order) -> Bool {
        
        checklistController.checklist_packed(order)
    }
    
    
    public func checklist_stamping(_ order: Order) -> Bool {
        
        checklistController.checklist_stamping(order)
    }
    
    
    public func checklist_shippingTransaction(_ order: Order) -> Bool {
        
        checklistController.checklist_shippingTransaction(order)
    }
    
    
    public func checklist_trackingNo(_ order: Order) -> Bool {
        
        checklistController.checklist_trackingNo(order)
    }
    
    
    public func checklist_shipped(_ order: Order) -> Bool {
        
        checklistController.checklist_shipped(order)
    }
    
        
    public func checklist_driveThru(_ order: Order) -> Bool {
        
        checklistController.checklist_driveThru(order)
    }
    
    
    public func checklist_received(_ order: Order) -> Bool {
        
        checklistController.checklist_received(order)
    }
    
    
    public func checklist_completed(_ order: Order) -> Bool {
        
        checklistController.checklist_completed(order)
    }
    
    
    public func checklist_buyerFeedback(_ order: Order) -> Bool {
        
        checklistController.checklist_buyerFeedback(order)
    }

    
    public func checklist_sellerFeedback(_ order: Order) -> Bool {
        
        checklistController.checklist_sellerFeedback(order)
    }
    
    
    public func pickingProgress(for order: Order) -> Percent {
        
        pickingProgressController.pickingProgress(for: order)
    }
    
    
    public func pickingVerificationProgress(for order: Order) -> Percent {
        
        pickingProgressController.pickingVerificationProgress(for: order)
    }
    
    
    public func laPosteTrackingStatus(for order: Order) -> LaPosteTrackingStatus? {
        
        trackingMiddleController.laPosteTrackingStatus(for: order)
    }
    
    
    public func checklistData(for order: Order) -> ChecklistData {
        
        return ChecklistData(sections: [
            .init(
                title: OrderMacroStatus.validatePayment.descriptionWithPicto,
                items: [
                    .init(
                        label: "Payment received",
                        checked: checklist_payment(order)
                    ),
                    .init(
                        label: "Register transaction",
                        checked: checklist_incomeTransaction(order)
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
                        checked: checklist_picking(order)
                    ),
                    .init(
                        label: {
                            let progress = pickingProgressController.pickingVerificationProgress(for: order)
                            if progress == 0% || progress == 100% {
                                return "Verify items"
                            } else {
                                return "Verify items - \(progress) complete"
                            }
                        }(),
                        checked: checklist_verification(order)
                    ),
                    .init(
                        label: "Pack order",
                        checked: checklist_packed(order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.ship.descriptionWithPicto,
                items: [
                    .init(
                        label: "Validate stamping",
                        checked: checklist_stamping(order)
                    ),
                    .init(
                        label: "Register transaction",
                        checked: checklist_shippingTransaction(order)
                    ),
                    .init(
                        label: "Input tracking no",
                        checked: checklist_trackingNo(order)
                    ),
                    .init(
                        label: "Mark Shipped",
                        checked: checklist_shipped(order)
                    ),
                    .init(
                        label: "Send drive thru",
                        checked: checklist_driveThru(order)
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
                        checked: checklist_received(order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.received.descriptionWithPicto,
                items: [
                    .init(
                        label: "Completed",
                        checked: checklist_completed(order)
                    ),
                    .init(
                        label: "Buyer feedback",
                        checked: checklist_buyerFeedback(order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.giveFeedback.descriptionWithPicto,
                items: [
                    .init(
                        label: "Give feedback",
                        checked: checklist_sellerFeedback(order)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.closed.descriptionWithPicto,
                items: []
            ),
        ])
    }


    // MARK: - Macro status
    
    
    public func macroStatus(for order: Order) -> OrderMacroStatus {
        
        macroStatusController.macroStatus(for: order)
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
                        checklist_verification($0) != checklist_verification($1)
                        && checklist_verification($0)
                        ||
                        checklist_verification($0) != checklist_verification($1)
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
    
    
    func loadLaPosteTrackingStatus(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await trackingMiddleController.loadLaPosteTrackingStatus(for: order, refetchStrategy, operationTag)
    }
    
    
    func loadFeedbacks(for order: Order, _ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await feedbackController.loadFeedbacks(for: order, refetchStrategy, operationTag)
    }
    
    
    func orderIsClosedForMoreThan30Days(_ order: Order) -> Bool {
        
        return (
            order.status.isOneOf(.completed, .cancelled, .purged)
            &&
            order.dateStatusChanged.days(to: Date()) > 30
        )
    }
    
    
    func orderNeedsRefreshLaPosteTrackingStatus(_ order: Order) -> Bool {
        
        macroStatus(for: order) == .inTransit
    }
    
    
    func orderNeedsRefreshFeedback(_ order: Order) -> Bool {
        
        macroStatus(for: order).isOneOf(.inTransit, .inTransitFor30PlusDays, .received, .giveFeedback)
    }
    
    
    func refreshOrders(_ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
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
    
    
    public func softRefreshOrders() async {
        
        await refreshOrders(.refetchOnlyIfInvalidated)
    }
    
    
    public func hardRefreshOrders(_ operationTag: OperationTag? = nil) async {
        
        await refreshOrders(.forceRefetch, operationTag)
    }
    
    
    func refresh(_ order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await loadOrders(refetchStrategy, operationTag)
    }
    
    
    public func softRefresh(_ order: Order, _ operationTag: OperationTag? = nil) async {
        
        await refresh(order, .refetchOnlyIfInvalidated, operationTag)
    }
    
    
    public func softRefresh(orderWithId orderId: Order.ID) async {
        
        await softRefresh(order(withId: orderId)!)
    }
    
    
    public func hardRefresh(_ order: Order, _ operationTag: OperationTag? = nil) async {
        
        await refresh(order, .forceRefetch, operationTag)
    }
    
    
    public func hardRefresh(orderWithId orderId: Order.ID, _ operationTag: OperationTag? = nil) async {
        
        await hardRefresh(order(withId: orderId)!, operationTag)
    }
    
    
    func refreshDetails(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        let strategy = hasDetails(for: order) ? refetchStrategy : .forceRefetch
        
        await loadDetails(for: order, strategy, operationTag)
    }
    
    
    public func softRefreshDetails(for order: Order) async {
        
        await refreshDetails(for: order, .refetchOnlyIfInvalidated)
    }


    public func softRefreshDetails(forOrderWithId orderId: Order.ID) async {
        
        await softRefreshDetails(for: order(withId: orderId)!)
    }
    
    
    public func hardRefreshDetails(for order: Order, _ operationTag: OperationTag? = nil) async {
        
        await refreshDetails(for: order, .forceRefetch, operationTag)
    }


    public func hardRefreshDetails(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag? = nil) async {
        
        await hardRefreshDetails(for: order(withId: orderId)!, operationTag)
    }
    
    
    func refreshItems(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        let strategy = hasItems(for: order) ? refetchStrategy : .forceRefetch
        
        await loadItems(for: order, strategy, operationTag)
    }
    
    
    public func softRefreshItems(for order: Order) async {
        
        await refreshItems(for: order, .refetchOnlyIfInvalidated)
    }
    
    
    public func softRefreshItems(forOrderWithId orderId: Order.ID) async {
        
        await softRefreshItems(for: order(withId: orderId)!)
    }
    
    
    public func hardRefreshItems(for order: Order, _ operationTag: OperationTag? = nil) async {
        
        await refreshItems(for: order, .forceRefetch, operationTag)
    }
    
    
    public func hardRefreshItems(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag? = nil) async {
        
        await hardRefreshItems(for: order(withId: orderId)!, operationTag)
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
                && checklist_stamping($0)
                && checklist_shippingTransaction($0)
                && checklist_trackingNo($0)
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



public struct ChecklistData {
    
    public let sections: [SectionData]
    
    public struct SectionData: Identifiable {
        
        public var id: String { title }
        public let title: String
        public let items: [ItemData]
    }
    
    public struct ItemData: Identifiable {
        
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
