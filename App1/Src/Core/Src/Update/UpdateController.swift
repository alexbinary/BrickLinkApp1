
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
     
        await enqueue { continuation in
            LoadColorsOperation(continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadColors: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is LoadColorsOperation })
    }
    
    
    // MARK: - Inventories
    
    
    func loadInventories() async {
            
        await enqueue { continuation in
            LoadInventoriesOperation(continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadInventories: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is LoadInventoriesOperation })
    }
    
    
    func loadInventory(withId inventoryId: InventoryItem.ID) async {
        
        await enqueue { continuation in
            LoadInventoryOperation(inventoryId: inventoryId, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadInventory: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is LoadInventoryOperation })
    }
    
    
    func isRunningOrIsScheduledToRun_loadInventory(withId inventoryId: InventoryItem.ID) -> Bool {
        
        return hasScheduledOrRunningOperation(matching: {
            if let op = $0 as? LoadInventoryOperation, op.inventoryId == inventoryId {
                return true
            }
            return false
        })
    }
    
    
    // MARK: - Orders
    
    
    func loadOrders() async {
        
        await enqueue { continuation in
            LoadOrdersOperation(continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrders: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is LoadOrdersOperation })
    }
    
    
    func loadDetails(for order: Order) async {
        
        await enqueue { continuation in
            LoadOrderDetailsOperation(order: order, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrderDetails: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is LoadOrderDetailsOperation })
    }
    
    
    func isRunningOrIsScheduledToRun_loadDetails(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(matching: {
            if let op = $0 as? LoadOrderDetailsOperation, op.order.id == order.id {
                return true
            }
            return false
        })
    }
    
    
    func loadItems(for order: Order) async {
        
        await enqueue { continuation in
            LoadOrderItemsOperation(order: order, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrderItems: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is LoadOrderItemsOperation })
    }
    
    
    func isRunningOrIsScheduledToRun_loadItems(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(matching: {
            if let op = $0 as? LoadOrderItemsOperation, op.order.id == order.id {
                return true
            }
            return false
        })
    }
    
    
    // MARK: - Order update
    
    
    func updateStatus(of order: Order, to status: OrderStatus) async {
        
        await enqueue { continuation in
            UpdateOrderStatusOperation(order: order, status: status, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_updateOrderStatus: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is UpdateOrderStatusOperation })
    }
    
    
    func isRunningOrIsScheduledToRun_updateStatus(of order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(matching: {
            if let op = $0 as? UpdateOrderStatusOperation, op.order.id == order.id {
                return true
            }
            return false
        })
    }
    
    
    func updateTrackingNo(of order: Order, to trackingNo: String) async {
        
        await enqueue { continuation in
            UpdateOrderTrackingNoOperation(order: order, trackingNo: trackingNo, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_updateOrderTrackingNo: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is UpdateOrderTrackingNoOperation })
    }
    
    
    func isRunningOrIsScheduledToRun_updateTrackingNo(of order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(matching: {
            if let op = $0 as? UpdateOrderTrackingNoOperation, op.order.id == order.id {
                return true
            }
            return false
        })
    }
    
    
    func sendDriveThru(for order: Order) async {
        
        await enqueue { continuation in
            SendDriveThruOperation(order: order, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_sendDriveThru: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is SendDriveThruOperation })
    }
    
    
    func isRunningOrIsScheduledToRun_sendDriveThru(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(matching: {
            if let op = $0 as? SendDriveThruOperation, op.order.id == order.id {
                return true
            }
            return false
        })
    }
    
    
    // MARK: - Tracking
    
    
    func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        await enqueue { continuation in
            UpdateLaPosteTrackingStatusOperation(trackingNo: trackingNo, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadLaPosteTrackingStatus: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is UpdateLaPosteTrackingStatusOperation })
    }
    
    
    func isRunningOrIsScheduledToRun_loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) -> Bool {
        
        return hasScheduledOrRunningOperation(matching: {
            if let op = $0 as? UpdateLaPosteTrackingStatusOperation, op.trackingNo == trackingNo {
                return true
            }
            return false
        })
    }
    
    
    // MARK: - Feedbacks
    
    
    func loadFeedbacks(for order: Order) async {
        
        await enqueue { continuation in
            LoadOrderFeedbacksOperation(order: order, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrderFeedbacks: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is LoadOrderFeedbacksOperation })
    }
    
    
    func isRunningOrIsScheduledToRun_loadFeedbacks(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(matching: {
            if let op = $0 as? LoadOrderFeedbacksOperation, op.order.id == order.id {
                return true
            }
            return false
        })
    }
    
    
    func postFeedback(for order: Order, rating: FeedbackRating, comment: String) async {
        
        await enqueue { continuation in
            PostOrderFeedbackOperation(order: order, rating: rating, comment: comment, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_postOrderFeedback: Bool {
        
        return hasScheduledOrRunningOperation(matching: { $0 is PostOrderFeedbackOperation })
    }
    
    
    func isRunningOrIsScheduledToRun_postFeedback(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(matching: {
            if let op = $0 as? PostOrderFeedbackOperation, op.order.id == order.id {
                return true
            }
            return false
        })
    }
    
    
    // MARK: - Queue
    

    private var queuedOperations: [any UpdateOperation] = []
    private var runningOperation: (any UpdateOperation)?
    
    
    private func hasScheduledOrRunningOperation(matching predicate: (any UpdateOperation) -> Bool) -> Bool {
        
        var ops = queuedOperations
        if let op = runningOperation { ops.append(op) }
        
        return ops.contains(where: { predicate($0) })
    }
    
    
    private func enqueue(_ builder: (CheckedContinuation<(),Never>) -> UpdateOperation) async {
        
        await withCheckedContinuation { continuation in
            enqueue(builder(continuation))
        }
    }
    
    
    private func enqueue(_ operation: any UpdateOperation) {
        
        queuedOperations.append(operation)
        
        Task { await dequeue() }
    }
    
    
    private func dequeue() async {
            
        guard runningOperation == nil, queuedOperations.count > 0 else {
            return
        }
            
        let operation = queuedOperations.removeFirst()
        
        runningOperation = operation
        await run(operation)
        runningOperation = nil
        
        await dequeue()
    }
    
    
    private func run(_ operation: any UpdateOperation) async {
        
        if operation is LoadColorsOperation {
            
            await run_loadColors()
            
        } else if operation is LoadInventoriesOperation {
            
            await run_loadInventories()
            
        } else if let op = operation as? LoadInventoryOperation {
            
            await run_loadInventory(withId: op.inventoryId)
            
        } else if operation is LoadOrdersOperation {
            
            await run_loadOrders()
            
        } else if let op = operation as? LoadOrderDetailsOperation {
            
            await run_loadDetails(for: op.order)
        
        } else if let op = operation as? LoadOrderItemsOperation {
            
            await run_loadItems(for: op.order)
        
        } else if let op = operation as? UpdateOrderStatusOperation {
            
            await run_updateStatus(of: op.order, to: op.status)
        
        } else if let op = operation as? UpdateOrderTrackingNoOperation {
            
            await run_updateTrackingNo(of: op.order, to: op.trackingNo)
            
        } else if let op = operation as? SendDriveThruOperation {
            
            await run_sendDriveThru(for: op.order)
            
        } else if let op = operation as? UpdateLaPosteTrackingStatusOperation {
            
            await run_loadLaPosteTrackingStatus(forTrackingNo: op.trackingNo)
            
        } else if let op = operation as? LoadOrderFeedbacksOperation {
            
            await run_loadFeedbacks(for: op.order)
            
        } else if let op = operation as? PostOrderFeedbackOperation {
            
            await run_postFeedback(for: op.order, rating: op.rating, comment: op.comment)
            
        } else {
            
            fatalError("Unknow update operation: \(operation)")
        }
        
        operation.resumeContinuation()
    }
    
    
    // MARK: - Operations run code
    
    
    private func run_loadColors() async {
     
        print("Loading colors")
        
        let blColors = await brickLinkAPIClient.fetchColors()
        let colors = blColors.map { LegoColor(fromBl: $0) }
        
        print("Loaded \(colors.count) colors")
        
        try! dataStore.setColors(colors)
        try! dataStore.save()
    }
    
    
    private func run_loadInventories() async {
        
        print("Loading inventories")
        
        let blInventories = await brickLinkAPIClient.fetchInventories()
        let inventories = blInventories.map { InventoryItem(fromBl: $0) }
        
        print("loaded \(inventories.count) inventories")
        
        try! dataStore.setInventories(inventories)
        try! dataStore.save()
    }
    
    
    private func run_loadInventory(withId inventoryId: InventoryItem.ID) async {
        
        print("Loading inventory \(inventoryId)")
        
        let blInventory = await brickLinkAPIClient.fetchInventory(inventoryId: inventoryId)
        let inventory = InventoryItem(fromBl: blInventory)
        
        try! dataStore.setInventory(inventory)
        try! dataStore.save()
    }
    
    
    private func run_loadOrders() async {
        
        print("Loading orders")
        
        let blOrders = await brickLinkAPIClient.fetchOrderSummaries()
        let orderSummaries = blOrders.map { Order(fromBl: $0) }.sorted { $0.date > $1.date }
        
        print("loaded \(orderSummaries.count) orders")
        
        try! dataStore.setOrderSummaries(orderSummaries)
        try! dataStore.save()
    }
    
    
    private func run_loadDetails(for order: Order) async {
        
        print("Loading order details \(order.id)")
        
        let blOrder = await brickLinkAPIClient.fetchOrderDetails(orderId: order.id)
        let orderDetails = OrderDetails(fromBl: blOrder)
        
        try! dataStore.setOrderDetail(orderDetails)
        try! dataStore.save()
    }
    
    
    private func run_loadItems(for order: Order) async {
        
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
    
    
    private func run_updateStatus(of order: Order, to status: OrderStatus) async {
        
        print("Update status \(status) for order \(order.id)")
        
        await brickLinkAPIClient.updateOrderStatus(orderId: order.id, status: status)
        
        await parallel([
            { await self.loadOrders() },
            { await self.loadDetails(for: order) },
        ])
    }
    
    
    private func run_updateTrackingNo(of order: Order, to trackingNo: String) async {
        
        print("Update tracking no \(trackingNo) for order \(order.id)")
        
        await brickLinkAPIClient.updateTrackingNo(orderId: order.id, trackingNo: trackingNo)
        
        await parallel([
            { await self.loadOrders() },
            { await self.loadDetails(for: order) },
        ])
    }
    
    
    private func run_sendDriveThru(for order: Order) async {
        
        print("Send drive thru for order \(order.id)")
        
        await brickLinkAPIClient.sendDriveThru(orderId: order.id, mailMe: true)
        
        await parallel([
            { await self.loadOrders() },
            { await self.loadDetails(for: order) },
        ])
    }
    
    
    // MARK: - Tracking
    
    
    private func run_loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        let status = await laPosteTrackingClient.fetchTrackingStatus(forTrackingNo: trackingNo)
    
        try! dataStore.setLaPosteTrackingStatus(status, forTrackingNo: trackingNo)
        try! dataStore.save()
    }
    
    
    
    // MARK: - Feedbacks
    
    
    private func run_loadFeedbacks(for order: Order) async {
        
        print("Loading order feedbacks \(order.id)")
        
        let blFeedbacks = await brickLinkAPIClient.fetchFeedbacks(orderId: order.id)
        let feedbacks = blFeedbacks.map { Feedback(fromBl: $0) }
        
        print("loaded \(feedbacks.count) feedbacks")
        
        try! dataStore.setOrderFeedbacks(feedbacks, forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    private func run_postFeedback(for order: Order, rating: FeedbackRating, comment: String) async {
            
        await brickLinkAPIClient.postFeedback(orderId: order.id, rating: rating.bricklinkFeedbackRating.rawValue, comment: comment)
        
        await loadFeedbacks(for: order)
    }
}
