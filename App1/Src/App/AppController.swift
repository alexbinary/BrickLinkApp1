
import SwiftUI


class AppController: ObservableObject {
    
    
    private let dataStore: DataStore = {
        
        let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
        return DataStore(dataFileUrl: URL(fileURLWithPath: path))
    }()
    
    private let blCredentials = Secrets.brickLinkAPICredentials
    
    let uploadStore: UploadStore
    let catalogStore: CatalogStore
    let inventoryStore: InventoryStore
    
    let transactionStore: TransactionStore
    let refundStore: RefundStore
    
    let orderStore: OrderStore
    let pickingStore: PickingStore
    let shippingStore: ShippingStore
    let trackingStore: TrackingStore
    let feedbackStore: FeedbackStore
    
    let uploadController: UploadController
    let pickingController: PickingController
    let shippingController: ShippingController
    let trackingController: TrackingController
    let feedbackController: FeedbackController
    
    let orderChecklistController: OrderChecklistController
    let resultController: ResultController
    
    let orderController: OrderController
    let stockController: StockController
    let reloadController: ReloadController
    
    
    init() {
        
        uploadStore = UploadStore(dataStore: dataStore)
        catalogStore = CatalogStore(dataStore: dataStore, blCredentials: blCredentials)
        inventoryStore = InventoryStore(dataStore: dataStore, blCredentials: blCredentials)
        
        transactionStore = TransactionStore(dataStore: dataStore)
        refundStore = RefundStore(dataStore: dataStore)
        
        orderStore = OrderStore(dataStore: dataStore, blCredentials: blCredentials)
        pickingStore = PickingStore(dataStore: dataStore)
        shippingStore = ShippingStore(dataStore: dataStore)
        trackingStore = TrackingStore(dataStore: dataStore)
        feedbackStore = FeedbackStore(dataStore: dataStore, blCredentials: blCredentials)
        
        uploadController = UploadController(uploadStore: uploadStore, catalogStore: catalogStore, inventoryStore: inventoryStore)
        pickingController = PickingController(orderStore: orderStore, pickingStore: pickingStore)
        shippingController = ShippingController(orderStore: orderStore)
        trackingController = TrackingController(orderStore: orderStore, trackingStore: trackingStore)
        feedbackController = FeedbackController(orderStore: orderStore, feedbackStore: feedbackStore)
        
        orderChecklistController = OrderChecklistController(orderStore: orderStore, pickingStore: pickingStore, shippingStore: shippingStore, feedbackStore: feedbackStore, transactionStore: transactionStore)
        resultController = ResultController(orderStore: orderStore, shippingStore: shippingStore, refundStore: refundStore, transactionStore: transactionStore)
        
        orderController = OrderController(orderStore: orderStore, orderChecklistController: orderChecklistController)
        stockController = StockController(orderStore: orderStore, pickingStore: pickingStore, inventoryStore: inventoryStore, orderController: orderController)
        reloadController = ReloadController(orderStore: orderStore, feedbackStore: feedbackStore, orderController: orderController, trackingController: trackingController)
        
        Task {
            await parallel([
                { await self.loadColors() },
                { await self.loadInventories() },
                { await self.loadOrderSummaries() },
            ])
        }
    }
    
    
    
    // MARK: - Colors
    
    
    private func loadColors() async {
        
        await catalogStore.loadColors()
    }
    
    
    
    // MARK: - Order summaries
    
    
    public var orderSummaries: [OrderSummary] {
        
        orderStore.orderSummaries
    }
    
    
    public func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        orderStore.orderSummary(forOrderWithId: orderId)
    }
    
    
    private func loadOrderSummaries() async {
        
        await orderStore.loadOrderSummaries()
    }
    
    
    public func reloadOrderSummaries() async {
        
        await orderStore.reloadOrderSummaries()
    }
    
    
    
    // MARK: - Orders details
    
    
    public var orderDetails: [OrderDetails] {
        
        orderStore.orderDetails
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderStore.orderDetails(forOrderWithId: orderId)
    }
    
    
    private func loadOrderDetails(forOrderWithId orderId: OrderSummary.ID) async {
        
        await orderStore.loadOrderDetails(forOrderWithId: orderId)
    }
    
    
    public func loadOrderDetailsIfMissing(forOrderWithId orderId: String) async {
        
        await orderStore.loadOrderDetailsIfMissing(forOrderWithId: orderId)
    }
    
    
    
    // MARK: - Order status, Tracking no, Drive thru
    
    
    public func updateOrderStatus(orderId: OrderSummary.ID, status: OrderStatus) async {
        
        await orderStore.updateOrderStatus(orderId: orderId, status: status)
    }
    
    
    public func sendDriveThru(orderId: OrderSummary.ID) async {
        
        await orderStore.sendDriveThru(orderId: orderId)
    }
    
    
    
    // MARK: - Shipping
    
    
    public func shippingCost(forOrderWithId orderId: OrderSummary.ID) -> Float? {
        
        shippingStore.shippingCost(forOrderWithId: orderId)
    }
    
    
    
    // MARK: - Stamping
    
    
    public func stamping(forOrderWithId orderId: OrderSummary.ID) -> String? {
        
        shippingStore.stamping(forOrderWithId: orderId)
    }
    
    
    public func orderIsValidatedWithoutStamping(orderId: OrderDetails.ID) -> Bool {
        
        shippingStore.orderIsValidatedWithoutStamping(orderId: orderId)
    }
    
    
    
    // MARK: - Order items
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderStore.orderItems(forOrderWithId: orderId)
    }
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID, fromItemIds itemsIds: [OrderItem.ID]) -> [OrderItem] {
        
        orderStore.orderItems(forOrderWithId: orderId, fromItemIds: itemsIds)
    }
    
    
    private func loadOrderItems(forOrderWithId orderId: OrderSummary.ID) async {
        
        await orderStore.loadOrderItems(forOrderWithId: orderId)
    }
    
    
    public func loadOrderItemsIfMissing(forOrderWithId orderId: String) async {
        
        await orderStore.loadOrderItemsIfMissing(forOrderWithId: orderId)
    }
    
    
    
    // MARK: - Pick & Verify
    
    
    public func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingStore.pickedItemIds(forOrderWithId: orderId)
    }
    
    
    public func verifiedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingStore.verifiedItemIds(forOrderWithId: orderId)
    }
    
    
    
    // MARK: - Order feedback
    
    
    public func orderFeedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        feedbackStore.orderFeedbacks(forOrderWithId: orderId)
    }
    
    
    private func loadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackStore.loadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    public func loadOrderFeedbacksIfMissing(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackStore.loadOrderFeedbacksIfMissing(forOrderWithId: orderId)
    }
    
    
    public func reloadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        await feedbackStore.reloadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    public func postOrderFeedback(orderId: OrderSummary.ID, rating: Int, comment: String) async {
        
        await feedbackStore.postOrderFeedback(orderId: orderId, rating: rating, comment: comment)
    }
    
    
    public func postPraiseOrderFeedback(orderId: OrderSummary.ID) async {
        
        await feedbackController.postPraiseOrderFeedback(orderId: orderId)
    }
    
    
    public func orderIsValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Bool {
        
        feedbackStore.orderIsValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    
    // MARK: - Upload
    
    
    public var uploadItems: [UploadItem] {
        
        uploadStore.uploadItems
    }
    
    
    
    // MARK: - Uploaded items
    
    
    public var uploadedItems: [UploadedItem] {
        
        uploadStore.uploadedItems
    }
    
    
    // MARK: - Inventory
    
    
    public var inventories: [InventoryItem] {
        
        inventoryStore.inventories
    }
    
    
    public func inventory(
        
        forType type: BrickLinkItemType,
        ref: String,
        comment: String?,
        colorId: String,
        condition: String
    
    ) -> InventoryItem? {
        
        inventoryStore.inventory(forType: type, ref: ref, comment: comment, colorId: colorId, condition: condition)
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        inventoryStore.inventory(for: uploadItem)
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        inventoryStore.inventories(forAllColorsOf: uploadItem)
    }
    
    
    private func loadInventories() async {
        
        await inventoryStore.loadInventories()
    }
    
    
    
    // MARK: - Transactions
    
    
    public func incomeTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionStore.incomeTransactions(forOrderWithId: orderId)
    }
    
    
    public func shippingTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionStore.shippingTransactions(forOrderWithId: orderId)
    }
    
    
    public func refundTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionStore.refundTransactions(forOrderWithId: orderId)
    }
    
    
    public func orderIsValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Bool {
        
        transactionStore.orderIsValidatedWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    public func orderIsValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Bool {
        
        transactionStore.orderIsValidatedWithoutShippingTransaction(orderId: orderId)
    }
    
    
    
    // MARK: - Refunds
    
    
    public func refunds(for order: OrderDetails) -> [OrderRefund] {
        
        refundStore.refunds(for: order)
    }
    
    
    
    // MARK: - Order checklist
    
    
    public func orderChecklistIncomeTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistIncomeTransaction(orderId)
    }
    
    
    public func orderChecklistShippingTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistShippingTransaction(orderId)
    }
    
    
    public func orderChecklistPicking(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistPicking(orderId)
    }
    
    
    public func orderChecklistVerification(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistVerification(orderId)
    }
    
    
    public func orderChecklistPacked(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistPacked(orderId)
    }
    
    
    public func orderChecklistShipped(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistShipped(orderId)
    }
    
    
    public func orderChecklistTrackingNo(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistTrackingNo(orderId)
    }
    
    
    public func orderChecklistDriveThru(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistDriveThru(orderId)
    }
    
    
    public func orderChecklistStamping(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistStamping(orderId)
    }
    
    
    public func orderChecklistReceived(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistReceived(orderId)
    }
    
    
    public func orderChecklistCompleted(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistCompleted(orderId)
    }
    
    
    public func orderChecklistBuyerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistBuyerFeedback(orderId)
    }
    
    
    public func orderChecklistSellerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistSellerFeedback(orderId)
    }
    
    
    public func orderChecklistUnchangedFor30Days(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistUnchangedFor30Days(orderId)
    }
    
    
    
    // MARK: - Order macro status
    
    
    public func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
        orderController.macroStatus(forOrderWithId: orderId)
    }
    
    
    
    // MARK: - Orders actions
    
    
    var ordersThatNeedCompletedAndGiveFeedback: [OrderSummary] {
        
        orderSummaries
            .filter { macroStatus(forOrderWithId: $0.id) == .inTransitFor30PlusDays }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
    }
    
    
    var ordersThatNeedGiveFeedback: [OrderSummary] {
        
        orderSummaries
            .filter { macroStatus(forOrderWithId: $0.id) == .giveFeedback }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
    }
    
    
    var ordersToShipAndSendDriveThru: [OrderSummary] {
        
        orderSummaries
            .filter {
                macroStatus(forOrderWithId: $0.id) == .ship
                && orderChecklistStamping($0.id)
                && orderChecklistShippingTransaction($0.id)
                && orderChecklistTrackingNo($0.id)
            }
            .sorted { $0.date > $1.date }
    }
    
    
    var ordersThatNeedAction: [OrderSummary] {
        
        ordersThatNeedCompletedAndGiveFeedback
        + ordersThatNeedGiveFeedback
        + ordersToShipAndSendDriveThru
    }
    
    
    public func performActionForAllOrders() async {
        
        for order in ordersThatNeedCompletedAndGiveFeedback {
        
            await updateOrderStatus(orderId: order.id, status: .completed)
            await postPraiseOrderFeedback(orderId: order.id)
        }
        
        for order in ordersThatNeedGiveFeedback {
            
            await postPraiseOrderFeedback(orderId: order.id)
        }
        
        for order in ordersToShipAndSendDriveThru {
            
            await updateOrderStatus(orderId: order.id, status: .shipped)
            await sendDriveThru(orderId: order.id)
        }
    }
    
    
    
    // MARK: - Tracking status
    
    
    public func reloadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        await trackingController.reloadLaPosteTrackingStatus(forOrderWithId: orderId)
    }
    
    
    
    // MARK: - Action orders
    
    
    public var actionOrders: [OrderSummary] {
        
        orderSummaries.filter {
            macroStatus(forOrderWithId: $0.id).isOneOf(
                .ship, .pickAndPack, .validatePayment, .giveFeedback, .inTransitFor30PlusDays
            )
        }
    }
}



// MARK: - Decoding



extension LegoColor {
    
    
    init(fromBl bl: BrickLinkColor) {
        
        self.id = "\(bl.colorId)"
        self.name = bl.colorName
        self.colorCode = bl.colorCode
    }
}


extension OrderSummary {
    
    
    init(fromBl bl: BrickLinkOrder) {
        
        self.id = "\(bl.orderId)"
        self.date = bl.dateOrdered
        self.buyer = bl.buyerName
        self.items = bl.totalCount
        self.lots = bl.uniqueCount
        
        self.subTotal = bl.cost.subtotal.floatValue
        self.grandTotal = bl.cost.grandTotal.floatValue
        self.costCurrencyCode = bl.cost.currencyCode
        
        self.dispSubTotal = bl.dispCost.subtotal.floatValue
        self.dispGrandTotal = bl.dispCost.grandTotal.floatValue
        self.dispCostCurrencyCode = bl.dispCost.currencyCode
        
        self.status = OrderStatus(rawValue: bl.status)!
        self.dateStatusChanged = bl.dateStatusChanged
        
        self.paymentStatus = PaymentStatus(rawValue: bl.payment.status)!
    }
}


extension OrderDetails {
    
    
    init(fromBl bl: BrickLinkOrder) {
        
        self.id = "\(bl.orderId)"
        self.date = bl.dateOrdered
        self.buyer = bl.buyerName
        self.items = bl.totalCount
        self.lots = bl.uniqueCount
        
        self.subTotal = bl.cost.subtotal.floatValue
        self.grandTotal = bl.cost.grandTotal.floatValue
        self.shippingCost = bl.cost.shipping!.floatValue
        self.costCurrencyCode = bl.cost.currencyCode
        
        self.dispSubTotal = bl.dispCost.subtotal.floatValue
        self.dispGrandTotal = bl.dispCost.grandTotal.floatValue
        self.dispShippingCost = bl.dispCost.shipping!.floatValue
        self.dispCostCurrencyCode = bl.dispCost.currencyCode
        
        self.status = OrderStatus(rawValue: bl.status)!
        self.driveThruSent = bl.driveThruSent!
        self.trackingNo = bl.shipping!.trackingNo
        self.totalWeight = bl.totalWeight!.floatValue
        
        self.shippingMethodId = bl.shipping!.methodId
        self.shippingMethodName = bl.shipping!.method
        self.shippingAddress = bl.shipping!.address.full.htmlUnescape()
        self.shippingAddressCountryCode = bl.shipping!.address.countryCode
        self.shippingAddressName = bl.shipping!.address.name.full
        
        self.remarks = bl.remarks
    }
}


extension OrderItem {
    
    
    init(fromBl bl: BrickLinkOrderItem, orderId: String) {
        
        self.inventoryId = "\(bl.inventoryId)"
        self.orderId = orderId
        self.condition = bl.newOrUsed
        self.colorId = "\(bl.colorId)"
        self.colorName = bl.colorName
        self.ref = bl.item.no
        self.name = bl.item.name.htmlUnescape()
        self.type = bl.item.type
        self.location = bl.remarks ?? ""
        self.comment = (bl.description ?? "").htmlUnescape()
        self.quantity = "\(bl.quantity)"
        self.unitPrice = bl.unitPrice.floatValue
        self.unitPriceFinal = bl.unitPriceFinal.floatValue
    }
}


extension InventoryItem {
    
    
    init(fromBl bl: BrickLinkInventoryItem) {
        
        self.id = "\(bl.inventoryId)"
        self.condition = bl.newOrUsed
        self.colorId = "\(bl.colorId)"
        self.ref = bl.item.no
        self.name = bl.item.name
        self.type = bl.item.type
        self.description = bl.description ?? ""
        self.remarks = bl.remarks ?? ""
        self.quantity = bl.quantity
        self.unitPrice = bl.unitPrice.floatValue
    }
}


extension CatalogItem {
    
    
    init(fromBl bl: BrickLinkCatalogItem) {
        
        self.name = bl.name.htmlUnescape()
    }
}


extension Feedback {
    
    
    init(fromBl bl: BrickLinkOrderFeedback) {
        
        self.id = bl.feedbackId
        self.orderId = "\(bl.orderId)"
        self.from = bl.from
        self.to = bl.to
        self.dateRated = bl.dateRated
        self.rating = bl.rating
        self.author = FeedbackAuthor(fromBl: bl.ratingOfBs)!
        self.comment = bl.comment
    }
}


extension FeedbackAuthor {
    
    
    init?(fromBl ratingOfBs: String) {
        
        switch ratingOfBs {
          
        case "B": self = .seller
        case "S": self = .buyer
            
        default: return nil
        }
    }
}


extension Data {
    
    
    func decode<T>() -> T where T: Decodable {
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        decoder.dateDecodingStrategy = .custom({ (decoder) in
            
            let stringValue = try! decoder.singleValueContainer().decode(String.self)
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
            
            return dateFormatter.date(from: stringValue)!
        })
        
        let decoded = try! decoder.decode(T.self, from: self)
        
        return decoded
    }
}
