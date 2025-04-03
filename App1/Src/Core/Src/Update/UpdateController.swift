
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
        
        return hasScheduledOrRunningOperation(ofType: LoadColorsOperation.self)
    }
    
    
    // MARK: - Inventories
    
    
    func loadInventories(_ refetchStrategy: RefetchStrategy) async {
            
        await enqueue { continuation in
            LoadInventoriesOperation(refetchStrategy: refetchStrategy, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadInventories: Bool {
        
        return hasScheduledOrRunningOperation(ofType: LoadInventoriesOperation.self)
    }
    
    
    func loadInventory(withId inventoryId: InventoryItem.ID, _ refetchStrategy: RefetchStrategy) async {
        
        await enqueue { continuation in
            LoadInventoryOperation(inventoryId: inventoryId, refetchStrategy: refetchStrategy, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadInventory: Bool {
        
        return hasScheduledOrRunningOperation(ofType: LoadInventoryOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_loadInventory(withId inventoryId: InventoryItem.ID) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: LoadInventoryOperation.self, matching: { $0.inventoryId == inventoryId })
    }
    
    
    // MARK: - Orders
    
    
    func loadOrders(_ refetchStrategy: RefetchStrategy) async {
        
        await enqueue { continuation in
            LoadOrdersOperation(refetchStrategy: refetchStrategy, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrders: Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadOrdersOperation.self, matching: { $0.refetchStrategy == .forceRefetch || self.ordersInvalidated })
    }
    
    
    func loadDetails(for order: Order, _ refetchStrategy: RefetchStrategy) async {
        
        await enqueue { continuation in
            LoadOrderDetailsOperation(order: order, refetchStrategy: refetchStrategy, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrderDetails: Bool {
        
        return hasScheduledOrRunningOperation(ofType: LoadOrderDetailsOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_loadDetails(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: LoadOrderDetailsOperation.self, matching: { $0.order.id == order.id })
    }
    
    
    func loadItems(for order: Order, _ refetchStrategy: RefetchStrategy) async {
        
        await enqueue { continuation in
            LoadOrderItemsOperation(order: order, refetchStrategy: refetchStrategy, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrderItems: Bool {
        
        return hasScheduledOrRunningOperation(ofType: LoadOrderItemsOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_loadItems(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: LoadOrderItemsOperation.self, matching: { $0.order.id == order.id })
    }
    
    
    // MARK: - Order update
    
    
    func updateStatus(of order: Order, to status: OrderStatus) async {
        
        await enqueue { continuation in
            UpdateOrderStatusOperation(order: order, status: status, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_updateOrderStatus: Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateOrderStatusOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_updateStatus(of order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateOrderStatusOperation.self, matching: { $0.order.id == order.id })
    }
    
    
    func isRunningOrIsScheduledToRun_updateStatus(of order: Order, to status: OrderStatus) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateOrderStatusOperation.self, matching: { $0.order.id == order.id && $0.status == status })
    }
    
    
    func updateTrackingNo(of order: Order, to trackingNo: TrackingNo) async {
        
        await enqueue { continuation in
            UpdateOrderTrackingNoOperation(order: order, trackingNo: trackingNo, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_updateOrderTrackingNo: Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateOrderTrackingNoOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_updateTrackingNo(of order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateOrderTrackingNoOperation.self, matching: { $0.order.id == order.id })
    }
    
    
    func sendDriveThru(for order: Order) async {
        
        await enqueue { continuation in
            SendDriveThruOperation(order: order, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_sendDriveThru: Bool {
        
        return hasScheduledOrRunningOperation(ofType: SendDriveThruOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_sendDriveThru(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: SendDriveThruOperation.self, matching: { $0.order.id == order.id })
    }
    
    
    // MARK: - Tracking
    
    
    func loadLaPosteTrackingStatus(forTrackingNo trackingNo: TrackingNo, _ refetchStrategy: RefetchStrategy) async {
        
        await enqueue { continuation in
            UpdateLaPosteTrackingStatusOperation(trackingNo: trackingNo, refetchStrategy: refetchStrategy, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadLaPosteTrackingStatus: Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateLaPosteTrackingStatusOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_loadLaPosteTrackingStatus(forTrackingNo trackingNo: TrackingNo) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateLaPosteTrackingStatusOperation.self, matching: { $0.trackingNo == trackingNo })
    }
    
    
    // MARK: - Feedbacks
    
    
    func loadFeedbacks(for order: Order, _ refetchStrategy: RefetchStrategy) async {
        
        await enqueue { continuation in
            LoadOrderFeedbacksOperation(order: order, refetchStrategy: refetchStrategy, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrderFeedbacks: Bool {
        
        return hasScheduledOrRunningOperation(ofType: LoadOrderFeedbacksOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_loadFeedbacks(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: LoadOrderFeedbacksOperation.self, matching: { $0.order.id == order.id })
    }
    
    
    func postFeedback(for order: Order, rating: FeedbackRating, comment: String) async {
        
        await enqueue { continuation in
            PostOrderFeedbackOperation(order: order, rating: rating, comment: comment, continuation: continuation)
        }
    }
    
    
    var isRunningOrIsScheduledToRun_postOrderFeedback: Bool {
        
        return hasScheduledOrRunningOperation(ofType: PostOrderFeedbackOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_postFeedback(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: PostOrderFeedbackOperation.self, matching: { $0.order.id == order.id })
    }
    
    
    // MARK: - Queue
    

    private var queuedOperations: [any UpdateOperation] = []
    private var runningOperation: (any UpdateOperation)?
    
    
    private func scheduledOrRunningOperation<T>(ofType type: T.Type, matching predicate: ((T) -> Bool)? = nil) -> T? {
        
        var ops = queuedOperations
        if let op = runningOperation { ops.append(op) }
        
        return ops.first(where: { $0 is T && predicate?($0 as! T) ?? true }) as? T
    }
    
    
    private func hasScheduledOrRunningOperation<T>(ofType type: T.Type, matching predicate: ((T) -> Bool)? = nil) -> Bool {
        
        scheduledOrRunningOperation(ofType: type, matching: predicate) != nil
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
            
        } else if let op = operation as? LoadInventoriesOperation {
            
            if inventoriesInvalidated || op.refetchStrategy == .forceRefetch {
                await run_loadInventories()
            }
            
        } else if let op = operation as? LoadInventoryOperation {
            
            await run_loadInventory(withId: op.inventoryId)
            
        } else if let op = operation as? LoadOrdersOperation {
            
            if ordersInvalidated || op.refetchStrategy == .forceRefetch {
                await run_loadOrders()
            }
            
        } else if let op = operation as? LoadOrderDetailsOperation {
            
            if detailsInvalidated(for: op.order) || op.refetchStrategy == .forceRefetch {
                await run_loadDetails(for: op.order)
            }
        
        } else if let op = operation as? LoadOrderItemsOperation {
            
            if itemsInvalidated(for: op.order) || op.refetchStrategy == .forceRefetch {
                await run_loadItems(for: op.order)
            }
        
        } else if let op = operation as? UpdateOrderStatusOperation {
            
            await run_updateStatus(of: op.order, to: op.status)
        
        } else if let op = operation as? UpdateOrderTrackingNoOperation {
            
            await run_updateTrackingNo(of: op.order, to: op.trackingNo)
            
        } else if let op = operation as? SendDriveThruOperation {
            
            await run_sendDriveThru(for: op.order)
            
        } else if let op = operation as? UpdateLaPosteTrackingStatusOperation {
            
            if trackingNoStatusInvalidated(op.trackingNo) || op.refetchStrategy == .forceRefetch {
                await run_loadLaPosteTrackingStatus(forTrackingNo: op.trackingNo)
            }
            
        } else if let op = operation as? LoadOrderFeedbacksOperation {
            
            if feedbacksInvalidated(for: op.order) || op.refetchStrategy == .forceRefetch {
                await run_loadFeedbacks(for: op.order)
            }
            
        } else if let op = operation as? PostOrderFeedbackOperation {
            
            await run_postFeedback(for: op.order, rating: op.rating, comment: op.comment)
            
        } else {
            
            fatalError("Unknow update operation: \(operation)")
        }
        
        operation.resumeContinuation()
    }
    
    
    // MARK: - Invalidate - Inventories
    
    
    private(set) var inventoriesInvalidated = true
    
    
    func invalidateInventories() {
        
        inventoriesInvalidated = true
    }
    
    func validateInventories() {
        
        inventoriesInvalidated = false
    }
    
    
    // MARK: - Invalidate - Orders
    
    
    private(set) var ordersInvalidated = true
    
    
    func invalidateOrders() {
        
        ordersInvalidated = true
    }
    
    func validateOrders() {
        
        ordersInvalidated = false
    }
    
    
    // MARK: - Invalidate - Orders details
    
    
    private var validatedOrderDetails: Set<Order.ID> = []
    
    
    func detailsInvalidated(for order: Order) -> Bool {
        
        validatedOrderDetails.contains(order.id) == false
    }
    
    func invalidateDetails(for order: Order) {
        
        validatedOrderDetails.remove(order.id)
    }
    
    func validateDetails(for order: Order) {
        
        validatedOrderDetails.insert(order.id)
    }
    
    
    // MARK: - Invalidate - Orders items
    
    
    private var validatedOrderItems: Set<Order.ID> = []
    
    
    func itemsInvalidated(for order: Order) -> Bool {
        
        validatedOrderItems.contains(order.id) == false
    }
    
    func invalidateItems(for order: Order) {
        
        validatedOrderItems.remove(order.id)
    }
    
    func validateItems(for order: Order) {
        
        validatedOrderItems.insert(order.id)
    }
    
    
    // MARK: - Invalidate - Tracking status
    
    
    private var validatedTrackingNoStatus: Set<TrackingNo> = []
    
    
    func trackingNoStatusInvalidated(_ trackingNo: TrackingNo) -> Bool {
        
        validatedTrackingNoStatus.contains(trackingNo) == false
    }
    
    func invalidateTrackingNoStatus(_ trackingNo: TrackingNo) {
        
        validatedTrackingNoStatus.remove(trackingNo)
    }
    
    func validateTrackingNoStatus(_ trackingNo: TrackingNo) {
        
        validatedTrackingNoStatus.insert(trackingNo)
    }
    
    
    // MARK: - Invalidate - Feedbacks
    
    
    private var validatedFeedbacks: Set<Order.ID> = []
    
    
    func feedbacksInvalidated(for order: Order) -> Bool {
        
        validatedFeedbacks.contains(order.id) == false
    }
    
    func invalidateFeedbacks(for order: Order) {
        
        validatedFeedbacks.remove(order.id)
    }
    
    func validateFeedbacks(for order: Order) {
        
        validatedFeedbacks.insert(order.id)
    }
    
    
    // MARK: - Operations run code
    
    
    private func run_loadColors() async {
     
        print("Loading colors...")
        
        let blColors = await brickLinkAPIClient.fetchColors()
        let colors = blColors.map { LegoColor(fromBl: $0) }
        
        print("loaded \(colors.count) colors")
        
        try! dataStore.setColors(colors)
        try! dataStore.save()
    }
    
    
    private func run_loadInventories() async {
        
        print("Loading inventories...")
        
        let blInventories = await brickLinkAPIClient.fetchInventories()
        let inventories = blInventories.map { InventoryItem(fromBl: $0) }
        
        print("loaded \(inventories.count) inventories")

        validateInventories()
        validateInventories(inventories)
        
        try! dataStore.setInventories(inventories)
        try! dataStore.save()
    }
    
    
    private func run_loadInventory(withId inventoryId: InventoryItem.ID) async {
        
        print("Loading inventory \(inventoryId)...")
        
        let blInventory = await brickLinkAPIClient.fetchInventory(inventoryId: inventoryId)
        let inventory = InventoryItem(fromBl: blInventory)
        
        print("loaded inventory \(inventoryId)")

        validateInventory(inventoryId)
        
        try! dataStore.setInventory(inventory)
        try! dataStore.save()
    }
    
    
    private func run_loadOrders() async {
        
        print("Loading orders...")
        
        let blOrders = await brickLinkAPIClient.fetchOrderSummaries()
        let orderSummaries = blOrders.map { Order(fromBl: $0) }.sorted { $0.date > $1.date }
        
        print("loaded \(orderSummaries.count) orders")

        validateOrders()
        
        try! dataStore.setOrderSummaries(orderSummaries)
        try! dataStore.save()
    }
    
    
    private func run_loadDetails(for order: Order) async {
        
        print("Loading details for order \(order.id)...")
        
        let blOrder = await brickLinkAPIClient.fetchOrderDetails(orderId: order.id)
        let orderDetails = OrderDetails(fromBl: blOrder)
        
        print("loaded details for order \(order.id)")

        validateDetails(for: order)
        
        try! dataStore.setOrderDetail(orderDetails)
        try! dataStore.save()
    }
    
    
    private func run_loadItems(for order: Order) async {
        
        print("Loading items for order \(order.id)...")
        
        let blBatches = await brickLinkAPIClient.fetchOrderItems(orderId: order.id)
        let batches = blBatches.map { blItems in blItems.map { OrderItem(fromBl: $0, orderId: order.id) } }
        
        print("loaded \(batches.count) batches with total \(batches.reduce(0){$0+$1.count}) items for order \(order.id)")

        validateItems(for: order)
        
        try! dataStore.setOrderItems(batches, forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    // MARK: - Order update
    
    
    private func run_updateStatus(of order: Order, to status: OrderStatus) async {
        
        print("Updating status \(status) for order \(order.id)...")
        
        await brickLinkAPIClient.updateOrderStatus(orderId: order.id, status: status)
        
        print("updated status \(status) for order \(order.id)")
        
        invalidateOrders()
        
        Task { await self.loadOrders(.refetchOnlyIfInvalidated) }
    }
    
    
    private func run_updateTrackingNo(of order: Order, to trackingNo: TrackingNo) async {
        
        print("Updating tracking no \(trackingNo) for order \(order.id)...")
        
        await brickLinkAPIClient.updateTrackingNo(orderId: order.id, trackingNo: trackingNo)
        
        print("updated tracking no \(trackingNo) for order \(order.id)")
        
        invalidateDetails(for: order)
        
        Task { await self.loadDetails(for: order, .refetchOnlyIfInvalidated) }
    }
    
    
    private func run_sendDriveThru(for order: Order) async {
        
        print("Sending drive thru for order \(order.id)...")
        
        await brickLinkAPIClient.sendDriveThru(orderId: order.id, mailMe: true)
        
        print("sent drive thru for order \(order.id)")
        
        invalidateDetails(for: order)
        
        Task { await self.loadDetails(for: order, .refetchOnlyIfInvalidated) }
    }
    
    
    // MARK: - Tracking
    
    
    private func run_loadLaPosteTrackingStatus(forTrackingNo trackingNo: TrackingNo) async {
        
        print("Fetching tracking status for tracking no \(trackingNo)...")
        
        let status = await laPosteTrackingClient.fetchTrackingStatus(forTrackingNo: trackingNo)
        
        print("fetched tracking status for tracking no \(trackingNo)")

        validateTrackingNoStatus(trackingNo)
    
        try! dataStore.setLaPosteTrackingStatus(status, forTrackingNo: trackingNo)
        try! dataStore.save()
    }
    
    
    // MARK: - Feedbacks
    
    
    private func run_loadFeedbacks(for order: Order) async {
        
        print("Loading feedbacks for order \(order.id)...")
        
        let blFeedbacks = await brickLinkAPIClient.fetchFeedbacks(orderId: order.id)
        let feedbacks = blFeedbacks.map { Feedback(fromBl: $0) }
        
        print("loaded \(feedbacks.count) feedbacks for order \(order.id)")

        validateFeedbacks(for: order)
        
        try! dataStore.setOrderFeedbacks(feedbacks, forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    private func run_postFeedback(for order: Order, rating: FeedbackRating, comment: String) async {
            
        await brickLinkAPIClient.postFeedback(orderId: order.id, rating: rating.bricklinkFeedbackRating.rawValue, comment: comment)
        
        invalidateFeedbacks(for: order)
        
        Task { await loadFeedbacks(for: order, .refetchOnlyIfInvalidated) }
    }
}



public enum RefetchStrategy {
    
    case refetchOnlyIfInvalidated
    case forceRefetch
}
