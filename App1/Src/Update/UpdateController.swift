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
    
    
    func loadColors(_ operationTag: OperationTag? = nil) async {
     
        await enqueue(LoadColorsOperation(operationTag: operationTag))
    }
    
    
    var isRunningOrIsScheduledToRun_loadColors: Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadColorsOperation.self)
    }
    
    
    // MARK: - Inventories
    
    
    func loadInventories(_ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
            
        await enqueue(LoadInventoriesOperation(refetchStrategy: refetchStrategy, operationTag: operationTag))
    }
    
    
    var isRunningOrIsScheduledToRun_loadInventories: Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadInventoriesOperation.self, matching: {
            $0.refetchStrategy == .forceRefetch || self.inventoriesInvalidated
        })
    }
    
    
    func loadInventory(withId inventoryId: InventoryItem.ID, _ refetchStrategy: RefetchStrategy) async {
        
        await enqueue(LoadInventoryOperation(inventoryId: inventoryId, refetchStrategy: refetchStrategy, operationTag: nil))
    }
    
    
    var isRunningOrIsScheduledToRun_loadInventory: Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadInventoryOperation.self, matching: {
            $0.refetchStrategy == .forceRefetch || self.inventoryInvalidated($0.inventoryId)
        })
    }
    
    
    func isRunningOrIsScheduledToRun_loadInventory(withId inventoryId: InventoryItem.ID) -> Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadInventoryOperation.self, matching: {
            $0.inventoryId == inventoryId &&
            $0.refetchStrategy == .forceRefetch || self.inventoryInvalidated($0.inventoryId)
        })
    }
    
    
    func updateInventory(inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float? = nil, remarks: String? = nil) async {
        
        await enqueue(UpdateInventoryOperation(inventoryId: inventoryId, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks, operationTag: nil))
    }
    
    
    var isRunningOrIsScheduledToRun_updateInventory: Bool {
        
        hasScheduledOrRunningOperation(ofType: UpdateInventoryOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_updateInventory(withId inventoryId: InventoryItem.ID) -> Bool {
        
        hasScheduledOrRunningOperation(ofType: UpdateInventoryOperation.self, matching: {
            $0.inventoryId == inventoryId
        })
    }
    
    
    // MARK: - Orders
    
    
    func loadOrders(_ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await enqueue(LoadOrdersOperation(refetchStrategy: refetchStrategy, operationTag: operationTag))
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrders: Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadOrdersOperation.self, matching: {
            $0.refetchStrategy == .forceRefetch || self.ordersInvalidated
        })
    }
    
    
    func loadDetails(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await enqueue(LoadOrderDetailsOperation(order: order, refetchStrategy: refetchStrategy, operationTag: operationTag))
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrderDetails: Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadOrderDetailsOperation.self, matching: {
            $0.refetchStrategy == .forceRefetch || self.detailsInvalidated(for: $0.order)
        })
    }
    
    
    func isRunningOrIsScheduledToRun_loadDetails(for order: Order) -> Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadOrderDetailsOperation.self, matching: {
            $0.order.id == order.id &&
            $0.refetchStrategy == .forceRefetch || self.detailsInvalidated(for: $0.order)
        })
    }
    
    
    func loadItems(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await enqueue(LoadOrderItemsOperation(order: order, refetchStrategy: refetchStrategy, operationTag: operationTag))
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrderItems: Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadOrderItemsOperation.self, matching: {
            $0.refetchStrategy == .forceRefetch || self.itemsInvalidated(for: $0.order)
        })
    }
    
    
    func isRunningOrIsScheduledToRun_loadItems(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: LoadOrderItemsOperation.self, matching: {
            $0.order.id == order.id &&
            $0.refetchStrategy == .forceRefetch || self.itemsInvalidated(for: $0.order)
        })
    }
    
    
    // MARK: - Order update
    
    
    func updateStatus(of order: Order, to status: OrderStatus) async {
        
        await enqueue(UpdateOrderStatusOperation(order: order, status: status, operationTag: nil))
    }
    
    
    var isRunningOrIsScheduledToRun_updateOrderStatus: Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateOrderStatusOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_updateStatus(of order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateOrderStatusOperation.self, matching: {
            $0.order.id == order.id
        })
    }
    
    
    func isRunningOrIsScheduledToRun_updateStatus(of order: Order, to status: OrderStatus) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateOrderStatusOperation.self, matching: {
            $0.order.id == order.id && $0.status == status
        })
    }
    
    
    func updateTrackingNo(of order: Order, to trackingNo: TrackingNo) async {
        
        await enqueue(UpdateOrderTrackingNoOperation(order: order, trackingNo: trackingNo, operationTag: nil))
    }
    
    
    var isRunningOrIsScheduledToRun_updateOrderTrackingNo: Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateOrderTrackingNoOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_updateTrackingNo(of order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: UpdateOrderTrackingNoOperation.self, matching: {
            $0.order.id == order.id
        })
    }
    
    
    func sendDriveThru(for order: Order) async {
        
        await enqueue(SendDriveThruOperation(order: order, operationTag: nil))
    }
    
    
    var isRunningOrIsScheduledToRun_sendDriveThru: Bool {
        
        return hasScheduledOrRunningOperation(ofType: SendDriveThruOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_sendDriveThru(for order: Order) -> Bool {
        
        return hasScheduledOrRunningOperation(ofType: SendDriveThruOperation.self, matching: {
            $0.order.id == order.id
        })
    }
    
    
    // MARK: - Tracking
    
    
    func loadLaPosteTrackingStatus(forTrackingNo trackingNo: TrackingNo, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await enqueue(UpdateLaPosteTrackingStatusOperation(trackingNo: trackingNo, refetchStrategy: refetchStrategy, operationTag: operationTag))
    }
    
    
    var isRunningOrIsScheduledToRun_loadLaPosteTrackingStatus: Bool {
        
        hasScheduledOrRunningOperation(ofType: UpdateLaPosteTrackingStatusOperation.self, matching: {
            $0.refetchStrategy == .forceRefetch || self.trackingNoStatusInvalidated(forTrackingNo: $0.trackingNo)
        })
    }
    
    
    func isRunningOrIsScheduledToRun_loadLaPosteTrackingStatus(forTrackingNo trackingNo: TrackingNo) -> Bool {
        
        hasScheduledOrRunningOperation(ofType: UpdateLaPosteTrackingStatusOperation.self, matching: {
            $0.trackingNo == trackingNo &&
            $0.refetchStrategy == .forceRefetch || self.trackingNoStatusInvalidated(forTrackingNo: $0.trackingNo)
        })
    }
    
    
    // MARK: - Feedbacks
    
    
    func loadFeedbacks(for order: Order, _ refetchStrategy: RefetchStrategy, _ operationTag: OperationTag? = nil) async {
        
        await enqueue(LoadOrderFeedbacksOperation(order: order, refetchStrategy: refetchStrategy, operationTag: operationTag))
    }
    
    
    var isRunningOrIsScheduledToRun_loadOrderFeedbacks: Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadOrderFeedbacksOperation.self, matching: {
            $0.refetchStrategy == .forceRefetch || self.feedbacksInvalidated(for: $0.order)
        })
    }
    
    
    func isRunningOrIsScheduledToRun_loadFeedbacks(for order: Order) -> Bool {
        
        hasScheduledOrRunningOperation(ofType: LoadOrderFeedbacksOperation.self, matching: {
            $0.order.id == order.id &&
            $0.refetchStrategy == .forceRefetch || self.feedbacksInvalidated(for: $0.order)
        })
    }
    
    
    func postFeedback(for order: Order, rating: FeedbackRating, comment: String) async {
        
        await enqueue(PostOrderFeedbackOperation(order: order, rating: rating, comment: comment, operationTag: nil))
    }
    
    
    var isRunningOrIsScheduledToRun_postOrderFeedback: Bool {
        
        hasScheduledOrRunningOperation(ofType: PostOrderFeedbackOperation.self)
    }
    
    
    func isRunningOrIsScheduledToRun_postFeedback(for order: Order) -> Bool {
        
        hasScheduledOrRunningOperation(ofType: PostOrderFeedbackOperation.self, matching: {
            $0.order.id == order.id
        })
    }
    
    
    // MARK: - Loading state
    
    
    func isRunningOrIsScheduledToRun_operations(withTag tag: UUID) -> Bool {
        
        hasScheduledOrRunningOperation(matching: { $0.operationTag == tag })
    }
    
    
    // MARK: - Queue
    

    private var queuedOperations: [any UpdateOperation] = []
    private var runningOperations: [any UpdateOperation] = []
    
    private var continuationsByOperationId: [UpdateOperationID: [CheckedContinuation<(),Never>]] = [:]
    
    
    private func scheduledOrRunningOperation(matching predicate: (UpdateOperation) -> Bool) -> UpdateOperation? {
        
        (queuedOperations + runningOperations).first(where: { predicate($0) })
    }
    
    
    private func hasScheduledOrRunningOperation(matching predicate: (UpdateOperation) -> Bool) -> Bool {
        
        scheduledOrRunningOperation(matching: predicate) != nil
    }
    
    
    private func scheduledOrRunningOperation<T>(ofType type: T.Type, matching predicate: ((T) -> Bool)? = nil) -> T? {
        
        scheduledOrRunningOperation(matching: { $0 is T && predicate?($0 as! T) ?? true }) as? T
    }
    
    
    private func hasScheduledOrRunningOperation<T>(ofType type: T.Type, matching predicate: ((T) -> Bool)? = nil) -> Bool {
        
        scheduledOrRunningOperation(ofType: type, matching: predicate) != nil
    }
    
    
    private func enqueue(_ operation: UpdateOperation) async {
        
        await withCheckedContinuation { continuation in

            continuationsByOperationId[operation.id] = [continuation]
            enqueue(operation)
        }
    }
    
    
    private func enqueue(_ operation: any UpdateOperation) {
        
        queuedOperations.append(operation)
        
        Task { await dequeue() }
    }
    
    
    private func dequeue() async {

        queuedOperations = queuedOperations.filter { $0.isWriteOperation } + queuedOperations.filter { $0.isReadOperation }
        
        for candidateOperation in queuedOperations {
            
            if candidateOperation.isReadOperation, let same = runningOperations.first(where: { $0.isSame(as: candidateOperation) }) {
             
                drop(candidateOperation, giveContinuationToRunningOperationWithId: same.id)
                continue
            }
            
            if runningOperations.isEmpty || runningOperations.allSatisfy({ operation(candidateOperation, canStartInParallelWithRunningOperation: $0) }) {
                
                start(candidateOperation)
            }
        }
    }
    
    
    private func drop(_ operation: any UpdateOperation, giveContinuationToRunningOperationWithId runningOperationId: UpdateOperationID) {
        
        queuedOperations.removeAll { $0.id == operation.id }
        
        continuationsByOperationId[runningOperationId]!.append(contentsOf: continuationsByOperationId[operation.id]!)
    }
    
    
    private func start(_ operation: any UpdateOperation) {
        
        queuedOperations.removeAll { $0.id == operation.id }
        runningOperations.append(operation)
        
        Task {
            
            await runAction(for: operation)
            runningOperations.removeAll { $0.id == operation.id }
            
            await dequeue()
        }
    }
    
    
    private func operation(_ candidateOperation: UpdateOperation, canStartInParallelWithRunningOperation runningOperation: UpdateOperation) -> Bool {
        
        if operation(candidateOperation, readsDataWrittenBy: runningOperation) {
            return false
        }

        return true
    }


    private func operation(_ readOperation: UpdateOperation, readsDataWrittenBy writeOperation: UpdateOperation) -> Bool {

        if readOperation is LoadInventoriesOperation {
            if writeOperation is UpdateInventoryOperation {
                return true
            }
        }
        
        if let readOp = readOperation as? LoadInventoryOperation {
            if let writeOp = writeOperation as? UpdateInventoryOperation, readOp.inventoryId == writeOp.inventoryId {
                return true
            }
        }
        
        if readOperation is LoadOrdersOperation {
            if writeOperation is UpdateOrderStatusOperation {
                return true
            }
        }
        
        if let readOp = readOperation as? LoadOrderDetailsOperation {
            if let writeOp = writeOperation as? UpdateOrderTrackingNoOperation, readOp.order.id == writeOp.order.id {
                return true
            }
            if let writeOp = writeOperation as? SendDriveThruOperation, readOp.order.id == writeOp.order.id {
                return true
            }
        }
        
        if let readOp = readOperation as? LoadOrderFeedbacksOperation {
            if let writeOp = writeOperation as? PostOrderFeedbackOperation, readOp.order.id == writeOp.order.id {
                return true
            }
        }
        
        return false
    }
    
    
    private func runAction(for operation: any UpdateOperation) async {
        
        if operation is LoadColorsOperation {
            
            await run_loadColors()
            
        } else if let op = operation as? LoadInventoriesOperation {
            
            if inventoriesInvalidated || op.refetchStrategy == .forceRefetch {
                await run_loadInventories()
            }
            
        } else if let op = operation as? LoadInventoryOperation {
            
            if inventoryInvalidated(op.inventoryId) || op.refetchStrategy == .forceRefetch {
                await run_loadInventory(withId: op.inventoryId)
            }
            
        } else if let op = operation as? UpdateInventoryOperation {
            
            await run_updateInventory(withId: op.inventoryId, addQuantity: op.addQuantity, unitPrice: op.unitPrice, remarks: op.remarks)
            
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
            
            if trackingNoStatusInvalidated(forTrackingNo: op.trackingNo) || op.refetchStrategy == .forceRefetch {
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
        
        resumeContinuations(for: operation)
    }
    
    
    private func resumeContinuations(for operation: UpdateOperation) {
        
        for continuation in continuationsByOperationId[operation.id] ?? [] {
            continuation.resume()
        }
        continuationsByOperationId[operation.id]?.removeAll()
    }
    
    
    // MARK: - Invalidate - Inventories
    
    
    private(set) var inventoriesInvalidated = true
    
    
    func invalidateInventories() {
        
        inventoriesInvalidated = true
    }
    
    func validateInventories() {
        
        inventoriesInvalidated = false
    }


    // MARK: - Invalidate - Inventory
    
    
    private var validatedInventories: Set<Order.ID> = []
    
    
    func inventoryInvalidated(_ inventoryId: InventoryItem.ID) -> Bool {
        
        validatedInventories.contains(inventoryId) == false
    }
    
    func invalidateInventory(_ inventoryId: InventoryItem.ID) {
        
        validatedInventories.remove(inventoryId)
    }
    
    func validateInventory(_ inventoryId: InventoryItem.ID) {
        
        validatedInventories.insert(inventoryId)
    }

    func validateInventories(_ inventories: [InventoryItem]) {
        
        for inventory in inventories {
            validateInventory(inventory.id)
        }
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
    
    
    private var invalidatedOrderDetails: Set<Order.ID> = []
    
    
    func detailsInvalidated(for order: Order) -> Bool {
        
        invalidatedOrderDetails.contains(order.id) == true
    }
    
    func invalidateDetails(for order: Order) {
        
        invalidatedOrderDetails.insert(order.id)
    }
    
    func validateDetails(for order: Order) {
        
        invalidatedOrderDetails.remove(order.id)
    }
    
    
    // MARK: - Invalidate - Orders items
    
    
    private var invalidatedOrderItems: Set<Order.ID> = []
    
    
    func itemsInvalidated(for order: Order) -> Bool {
        
        invalidatedOrderItems.contains(order.id) == true
    }
    
    func invalidateItems(for order: Order) {
        
        invalidatedOrderItems.insert(order.id)
    }
    
    func validateItems(for order: Order) {
        
        invalidatedOrderItems.remove(order.id)
    }
    
    
    // MARK: - Invalidate - Tracking status
    
    
    private var validatedTrackingNoStatus: Set<TrackingNo> = []
    
    
    func trackingNoStatusInvalidated(forTrackingNo trackingNo: TrackingNo) -> Bool {
        
        validatedTrackingNoStatus.contains(trackingNo) == false
    }
    
    func invalidateTrackingNoStatus(forTrackingNo trackingNo: TrackingNo) {
        
        validatedTrackingNoStatus.remove(trackingNo)
    }
    
    func validateTrackingNoStatus(forTrackingNo trackingNo: TrackingNo) {
        
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
    
    
    private func run_updateInventory(withId inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float?, remarks: String?) async {
        
        print("Updating inventory \(inventoryId)...")
        
        let blInventory = await brickLinkAPIClient.updateInventory(inventoryId: inventoryId, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks)
        let inventory = InventoryItem(fromBl: blInventory)
        
        print("updated inventory \(inventoryId)")
        
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

        validateTrackingNoStatus(forTrackingNo: trackingNo)
    
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



enum RefetchStrategy {
    
    case refetchOnlyIfInvalidated
    case forceRefetch
}


typealias OperationTag = UUID

extension OperationTag {
    
    static var new: OperationTag {
        
        OperationTag()
    }
}
