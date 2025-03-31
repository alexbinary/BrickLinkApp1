
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
    
    
    func loadOrders() async {
        
        await updateController.loadOrders()
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
    
    
    // MARK: - Orders details
    
    
    var orderDetails: [OrderDetails] {
        
        dataStore.orderDetails
    }
    
    
    func details(for order: Order) -> OrderDetails? {
        
        orderDetails.first { $0.id == order.id }
    }
    
    
    func loadDetails(for order: Order) async {
        
        await updateController.loadDetails(for: order)
    }
    
    
    func loadDetailsIfMissing(for order: Order) async {
        
        if !orderDetails.contains(where: { $0.id == order.id }) {
            
            await loadDetails(for: order)
        }
    }
    
    
    func reloadDetails(for order: Order) async {
        
        if orderDetails.contains(where: { $0.id == order.id }) {
            
            await loadDetails(for: order)
        }
    }
    
    
    // MARK: - Order status, Tracking no, Drive thru
    
    
    func updateStatus(of order: Order, to status: OrderStatus) async {
        
        await updateController.updateStatus(of: order, to: status)
    }
    
    
    func updateTrackingNo(of order: Order, to trackingNo: String) async {
        
        await updateController.updateTrackingNo(of: order, to: trackingNo)
    }
    
    
    func sendDriveThru(for order: Order) async {
        
        await updateController.sendDriveThru(for: order)
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
        
        await updateController.loadItems(for: order)
    }
    
    
    func loadItemsIfMissing(for order: Order) async {
        
        if !dataStore.orderItemsByOrderId.keys.contains(where: { $0 == order.id }) {
            
            await loadItems(for: order)
        }
    }
}
