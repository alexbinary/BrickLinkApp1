
import Foundation



@MainActor
class OrderCoreController {
    
    
    private let dataStore: DataStore
    private let updateController: UpdateController
    
    
    init(_ dataStore: DataStore, _ updateController: UpdateController) {
     
        self.dataStore = dataStore
        self.updateController = updateController
    }
    
    
    // MARK: - Order summaries
    
    
    var orders: [Order] {
        
        dataStore.orderSummaries
    }
    
    
    func order(withId orderId: Order.ID) -> Order? {
        
        orders.first { $0.id == orderId }
    }
    
    
    func loadOrders(_ refetchStrategy: RefetchStrategy = .forceRefetch) async {
        
        await updateController.loadOrders(refetchStrategy)
    }
    
    
    func loadOrdersIfMissing() async {
        
        if orders.isEmpty {
        
            await loadOrders()
        }
    }
    
    
    func reloadOrders() async {
        
        if !orders.isEmpty {
        
            await loadOrders()
        }
    }
    
    
    var isLoadingOrders: Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadOrders
    }
    
    
    // MARK: - Orders details
    
    
    var orderDetails: [OrderDetails] {
        
        dataStore.orderDetails
    }
    
    
    func details(for order: Order) -> OrderDetails? {
        
        orderDetails.first { $0.id == order.id }
    }
    
    
    func loadDetails(for order: Order, _ refetchStrategy: RefetchStrategy = .forceRefetch) async {
        
        await updateController.loadDetails(for: order, refetchStrategy)
    }
    
    
    func loadDetailsIfMissing(for order: Order) async {
        
        if !orderDetails.contains(where: { $0.id == order.id }) {
            
            await loadDetails(for: order, .forceRefetch)
        }
    }
    
    
    func reloadDetails(for order: Order) async {
        
        if orderDetails.contains(where: { $0.id == order.id }) {
            
            await loadDetails(for: order)
        }
    }
    
    
    var isLoadingOrderDetails: Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadOrderDetails
    }
    

    func isLoadingDetails(for order: Order) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadDetails(for: order)
    }
    
    
    // MARK: - Order items
    
    
    func items(for order: Order) -> [OrderItem] {
        
        (dataStore.orderItemsByOrderId[order.id] ?? []).reduce([], { $0 + $1 })
    }
    
    
    func items(for order: Order, fromItemIds itemsIds: [OrderItem.ID]) -> [OrderItem] {
        
        let items = items(for: order)
        
        return itemsIds.map { id in items.first { $0.id == id }! }
    }
    
    
    func loadItems(for order: Order) async {
        
        await updateController.loadItems(for: order, .forceRefetch)
    }
    
    
    func loadItemsIfMissing(for order: Order) async {
        
        if !dataStore.orderItemsByOrderId.keys.contains(where: { $0 == order.id }) {
            
            await loadItems(for: order)
        }
    }
    
    
    var isLoadingOrderItems: Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadOrderItems
    }
    
    
    func isLoadingItems(for order: Order) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadItems(for: order)
    }
    
    
    // MARK: - Order status, Tracking no, Drive thru
    
    
    func updateStatus(of order: Order, to status: OrderStatus) async {
        
        await updateController.updateStatus(of: order, to: status)
    }
    
    
    var isUpdatingOrderStatus: Bool {
        
        updateController.isRunningOrIsScheduledToRun_updateOrderStatus
    }
    
    
    func isUpdatingStatus(of order: Order) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_updateStatus(of: order)
    }
    
    
    func isUpdatingStatus(of order: Order, to status: OrderStatus) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_updateStatus(of: order, to: status)
    }
    
    
    func updateTrackingNo(of order: Order, to trackingNo: TrackingNo) async {
        
        await updateController.updateTrackingNo(of: order, to: trackingNo)
    }
    
    
    var isUpdatingOrderTrackingNo: Bool {
        
        updateController.isRunningOrIsScheduledToRun_updateOrderTrackingNo
    }
    
    
    func isUpdatingTrackingNo(of order: Order) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_updateTrackingNo(of: order)
    }
    
    
    func sendDriveThru(for order: Order) async {
        
        await updateController.sendDriveThru(for: order)
    }
    
    
    var isSendingDriveThru: Bool {
        
        updateController.isRunningOrIsScheduledToRun_sendDriveThru
    }
    
    
    func isSendingDriveThru(for order: Order) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_sendDriveThru(for: order)
    }
}
