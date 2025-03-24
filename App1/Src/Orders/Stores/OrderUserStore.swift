
import Foundation



@Observable
class OrderUserStore {
    
    
    private let orderDataAccess: OrderDataAccess
    private let orderStore: OrderStore
    private let orderChecklistStore: OrderChecklistStore
    private let orderActionStore: OrderActionStore
    private let reloadController: ReloadController
    
    
    init(_ orderDataAccess: OrderDataAccess, _ orderStore: OrderStore, _ orderChecklistStore: OrderChecklistStore, _ orderActionStore: OrderActionStore, _ reloadController: ReloadController) {
        self.orderDataAccess = orderDataAccess
        self.orderStore = orderStore
        self.orderChecklistStore = orderChecklistStore
        self.orderActionStore = orderActionStore
        self.reloadController = reloadController
    }
    
    
    // MARK: - Summaries
    
    
    public var orderSummaries: [OrderSummary] {
        
        orderDataAccess.orderSummaries
    }
    
    
    public func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        orderDataAccess.orderSummary(forOrderWithId: orderId)
    }
    
    
    public func loadOrderSummaries() async {
        
        await orderDataAccess.loadOrderSummaries()
    }
    
    
    // MARK: - Details
    
    
    public var orderDetails: [OrderDetails] {
        
        orderDataAccess.orderDetails
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderDataAccess.orderDetails(forOrderWithId: orderId)
    }
    
    
    // MARK: - Items
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderDataAccess.orderItems(forOrderWithId: orderId)
    }
    
    
    public func loadOrderItemsIfMissing(forOrderWithId orderId: String) async {
        
        await orderDataAccess.loadOrderItemsIfMissing(forOrderWithId: orderId)
    }
    
    
    // MARK: - Update
    
    
    public func updateOrderStatus(orderId: OrderSummary.ID, status: OrderStatus) async {
        
        await orderDataAccess.updateOrderStatus(orderId: orderId, status: status)
    }
    
    
    public func updateTrackingNo(forOrderWithId orderId: OrderSummary.ID, trackingNo: String) async {
        
        await orderDataAccess.updateTrackingNo(forOrderWithId: orderId, trackingNo: trackingNo)
    }
    
    
    public func sendDriveThru(orderId: OrderSummary.ID) async {
        
        await orderDataAccess.sendDriveThru(orderId: orderId)
    }
    
    
    // MARK: - Reload
    
    
    public func forceRefreshOrder(orderId: OrderSummary.ID) async {
        
        await reloadController.forceRefreshOrder(orderId: orderId)
    }
    
    
    // MARK: - Macro status
    
    
    public func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
        orderStore.macroStatus(forOrderWithId: orderId)
    }
    
    
    public func ordersMainListSections(restrictingToOrdersMatching searchText: String) -> [OrdersMainListSection] {
        
        orderStore.ordersMainListSections(restrictingToOrdersMatching: searchText)
    }
    
    
    public func refreshOrdersMainList() async {
        
        await reloadController.refreshOrdersMainList()
    }
    
    
    // MARK: - Checklist
    
    
    public func orderChecklistPayment(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistPayment(orderId)
    }
    
    
    public func orderChecklistIncomeTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistIncomeTransaction(orderId)
    }
    
    
    public func orderChecklistPicking(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistPicking(orderId)
    }
    
    
    public func orderChecklistVerification(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistVerification(orderId)
    }
    
    
    public func orderChecklistPacked(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistPacked(orderId)
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
    
    
    public func orderChecklistShipped(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistShipped(orderId)
    }
    
        
    public func orderChecklistDriveThru(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistDriveThru(orderId)
    }
    
    
    public func orderChecklistCompleted(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistCompleted(orderId)
    }
    
    
    public func orderChecklistSellerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistSellerFeedback(orderId)
    }
    
    
    public func orderChecklistUnchangedFor30Days(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistUnchangedFor30Days(orderId)
    }
    
    
    public func checklist(forOrderWithId orderId: OrderSummary.ID) -> Checklist {
        
        orderChecklistStore.checklist(forOrderWithId: orderId)
    }
    
    
    // MARK: - Actions
    
    
    public var ordersThatNeedCompletedAndGiveFeedback: [OrderSummary] {
        
        orderActionStore.ordersThatNeedCompletedAndGiveFeedback
    }
    
    
    public var ordersThatNeedGiveFeedback: [OrderSummary] {
        
        orderActionStore.ordersThatNeedGiveFeedback
    }
    
    
    public var ordersToShipAndSendDriveThru: [OrderSummary] {
        
        orderActionStore.ordersToShipAndSendDriveThru
    }
    
    
    public var ordersThatNeedAction: [OrderSummary] {
        
        orderActionStore.ordersThatNeedAction
    }
    
    
    public func performActionForAllOrders() async {
        
        await orderActionStore.performActionForAllOrders()
    }
    
    
    // MARK: - Sidebar
    
    
    public var numberForSidebarBadge: Int {
        
        orderStore.numberForSidebarBadge
    }
}
