
import Foundation



@MainActor
@Observable
class UpdateController {
    
    
    private let dataStore: DataStore
    private let brickLinkAPIClient: BrickLinkAPIClient
    private let laPosteTrackingClient: LaPosteTrackingClient
    
    
    init(_ dataStore: DataStore, _ brickLinkAPIClient: BrickLinkAPIClient, _ laPosteTrackingClient: LaPosteTrackingClient) {
        
        self.dataStore = dataStore
        self.brickLinkAPIClient = brickLinkAPIClient
        self.laPosteTrackingClient = laPosteTrackingClient
    }
    
    
    // MARK: - Colors
    
    
    func loadColors() async {
     
        print("Loading colors")
        
        let blColors = await brickLinkAPIClient.fetchColors()
        let colors = blColors.map { LegoColor(fromBl: $0) }
        
        print("Loaded \(colors.count) colors")
        
        try! dataStore.setColors(colors)
        try! dataStore.save()
    }
    
    
    // MARK: - Inventories
    
    
    func loadInventories() async {
        
        print("Loading inventories")
        
        let blInventories = await brickLinkAPIClient.fetchInventories()
        let inventories = blInventories.map { InventoryItem(fromBl: $0) }
        
        print("loaded \(inventories.count) inventories")
        
        try! dataStore.setInventories(inventories)
        try! dataStore.save()
    }
    
    
    func loadInventory(withId inventoryId: InventoryItem.ID) async {
        
        print("Loading inventory \(inventoryId)")
        
        let blInventory = await brickLinkAPIClient.fetchInventory(inventoryId: inventoryId)
        let inventory = InventoryItem(fromBl: blInventory)
        
        try! dataStore.setInventory(inventory)
        try! dataStore.save()
    }
    
    
    // MARK: - Orders
    

    func loadOrders() async {
        
        print("Loading orders")
        
        let blOrders = await brickLinkAPIClient.fetchOrderSummaries()
        let orderSummaries = blOrders.map { Order(fromBl: $0) }.sorted { $0.date > $1.date }
        
        print("loaded \(orderSummaries.count) orders")
        
        try! dataStore.setOrderSummaries(orderSummaries)
        try! dataStore.save()
    }
    
    
    func loadDetails(for order: Order) async {
        
        print("Loading order details \(order.id)")
        
        let blOrder = await brickLinkAPIClient.fetchOrderDetails(orderId: order.id)
        let orderDetails = OrderDetails(fromBl: blOrder)
        
        try! dataStore.setOrderDetail(orderDetails)
        try! dataStore.save()
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
    
    
    // MARK: - Order update
    
    
    func updateStatus(of order: Order, to status: OrderStatus) async {
        
        print("Update status \(status) for order \(order.id)")
        
        await brickLinkAPIClient.updateOrderStatus(orderId: order.id, status: status)
        
        await parallel([
            { await self.loadOrders() },
            { await self.loadDetails(for: order) },
        ])
    }
    
    
    func updateTrackingNo(of order: Order, to trackingNo: String) async {
        
        print("Update tracking no \(trackingNo) for order \(order.id)")
        
        await brickLinkAPIClient.updateTrackingNo(orderId: order.id, trackingNo: trackingNo)
        
        await parallel([
            { await self.loadOrders() },
            { await self.loadDetails(for: order) },
        ])
    }
    
    
    func sendDriveThru(for order: Order) async {
        
        print("Send drive thru for order \(order.id)")
        
        await brickLinkAPIClient.sendDriveThru(orderId: order.id, mailMe: true)
        
        await parallel([
            { await self.loadOrders() },
            { await self.loadDetails(for: order) },
        ])
    }
    
    
    // MARK: - Tracking
    
    
    func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        let status = await laPosteTrackingClient.fetchTrackingStatus(forTrackingNo: trackingNo)
    
        try! dataStore.setLaPosteTrackingStatus(status, forTrackingNo: trackingNo)
        try! dataStore.save()
    }
    
    
    // MARK: - Feedbacks
    
    
    func loadFeedbacks(for order: Order) async {
        
        print("Loading order feedbacks \(order.id)")
        
        let blFeedbacks = await brickLinkAPIClient.fetchFeedbacks(orderId: order.id)
        let feedbacks = blFeedbacks.map { Feedback(fromBl: $0) }
        
        print("loaded \(feedbacks.count) feedbacks")
        
        try! dataStore.setOrderFeedbacks(feedbacks, forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    func postFeedback(for order: Order, rating: FeedbackRating, comment: String) async {
        
        await brickLinkAPIClient.postFeedback(orderId: order.id, rating: rating.bricklinkFeedbackRating.rawValue, comment: comment)
        
        await loadFeedbacks(for: order)
    }
}
