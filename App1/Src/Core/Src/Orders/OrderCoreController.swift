
import Foundation



@MainActor
class OrderCoreController {
    
    
    private let dataStore: DataStore
    private let brickLinkAPIClient: BrickLinkAPIClient
    
    
    init(_ dataStore: DataStore, _ brickLinkAPIClient: BrickLinkAPIClient) {
     
        self.dataStore = dataStore
        self.brickLinkAPIClient = brickLinkAPIClient
    }
    
    
    // MARK: - Order summaries
    
    
    var orders: [Order] {
        
        dataStore.orderSummaries
    }
    
    
    func order(withId orderId: Order.ID) -> Order? {
        
        orders.first { $0.id == orderId }
    }
    
    
    func loadOrders() async {
        
        print("Loading orders")
        
        let blOrders = await brickLinkAPIClient.fetchOrderSummaries()
        let orderSummaries = blOrders.map { Order(fromBl: $0) }.sorted { $0.date > $1.date }
        
        print("loaded \(orderSummaries.count) orders")
        
        try! dataStore.setOrderSummaries(orderSummaries)
        try! dataStore.save()
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
        
        print("Loading order details \(order.id)")
        
        let blOrder = await brickLinkAPIClient.fetchOrderDetails(orderId: order.id)
        let orderDetails = OrderDetails(fromBl: blOrder)
        
        try! dataStore.setOrderDetail(orderDetails)
        try! dataStore.save()
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
        
        print("Update status \(status) for order \(order.id)")
        
        await brickLinkAPIClient.updateOrderStatus(orderId: order.id, status: status)
        
        await parallel([
            { await self.reloadOrders() },
            { await self.reloadDetails(for: order) },
        ])
    }
    
    
    func updateTrackingNo(of order: Order, to trackingNo: String) async {
        
        print("Update tracking no \(trackingNo) for order \(order.id)")
        
        await brickLinkAPIClient.updateTrackingNo(orderId: order.id, trackingNo: trackingNo)
        
        await parallel([
            { await self.reloadOrders() },
            { await self.reloadDetails(for: order) },
        ])
    }
    
    
    func sendDriveThru(for order: Order) async {
        
        print("Send drive thru for order \(order.id)")
        
        await brickLinkAPIClient.sendDriveThru(orderId: order.id, mailMe: true)
        
        await parallel([
            { await self.reloadOrders() },
            { await self.reloadDetails(for: order) },
        ])
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
        
        print("Loading order items \(order.id)")
        
        let blBatches = await brickLinkAPIClient.fetchOrderItems(orderId: order.id)
        
        let batches = blBatches.map { blItems in
            blItems.map { OrderItem(fromBl: $0, orderId: order.id) }
        }
        
        print("loaded \(batches.count) batches with total \(batches.reduce(0){$0+$1.count}) items")
        
        try! dataStore.setOrderItems(batches, forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    func loadItemsIfMissing(for order: Order) async {
        
        if !dataStore.orderItemsByOrderId.keys.contains(where: { $0 == order.id }) {
            
            await loadItems(for: order)
        }
    }
}
