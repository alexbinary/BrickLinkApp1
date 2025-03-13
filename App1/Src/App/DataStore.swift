
import Foundation



class DataStore {
    
    
    private let dataFileUrl: URL
    
    private var data: DataRoot? = nil
    
    
    init(dataFileUrl: URL) {
        
        print("Init data store with file \(dataFileUrl)")
        
        self.dataFileUrl = dataFileUrl
        
        try! loadDataFromFile()
        try! save()
    }
    
    
    private func loadDataFromFile() throws {
            
        let decoder = JSONDecoder()
        decoder.allowsJSON5 = true
        decoder.dateDecodingStrategy = .iso8601
        
        if let rawData = try? Data(contentsOf: dataFileUrl) {
        
            let decodedData = try! decoder.decode(DataRoot.self, from: rawData)
            self.data = decodedData
            
        } else {
            
            self.data = DataRoot()
        }
    }
    
    
    private func write() throws {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let rawData = try encoder.encode(data)
        try rawData.write(to: self.dataFileUrl)
    }
    
    
    public func save() throws {
        
        try write()
    }
    
    
    // MARK: - Public setters & getters
    
    
    public var colors: [LegoColor] {
        
        data?.colors ?? []
    }
    
    
    public func setColors(_ colors: [LegoColor]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.colors = colors
    }
    
    
    public var inventories: [InventoryItem] {
        
        data?.inventories ?? []
    }
    
    
    public func setInventories(_ inventories: [InventoryItem]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.inventories = inventories.sorted { $0.id < $1.id }
    }
    
    
    public func setInventory(_ inventory: InventoryItem) throws {
        
        var inventories = self.inventories
        
        if let index = inventories.firstIndex(where: { $0.id == inventory.id }) {
            inventories[index] = inventory
        } else {
            inventories.append(inventory)
        }
        
        try setInventories(inventories)
    }
    
    
    public var orderSummaries: [OrderSummary] {
        
        data?.orderSummaries ?? []
    }
    
    
    public func setOrderSummaries(_ orderSummaries: [OrderSummary]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderSummaries = orderSummaries
    }
    
    
    public var orderDetails: [OrderDetails] {
        
        data?.orderDetails ?? []
    }
    
    
    public func setOrderDetails(_ orderDetails: [OrderDetails]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderDetails = orderDetails
    }
    
    
    public func setOrderDetail(_ orderDetail: OrderDetails) throws {
        
        var orderDetails = self.orderDetails
        
        if let index = orderDetails.firstIndex(where: { $0.id == orderDetail.id }) {
            orderDetails[index] = orderDetail
        } else {
            orderDetails.append(orderDetail)
        }
        
        try setOrderDetails(orderDetails)
    }
    
    
    public var orderItemsByOrderId: [OrderSummary.ID: [[OrderItem]]] {
        
        data?.orderItemsByOrderId ?? [:]
    }
    
    
    public func setOrderItemsByOrderId(_ orderItemsByOrderId: [OrderSummary.ID: [[OrderItem]]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderItemsByOrderId = orderItemsByOrderId
    }
    
    
    public func setOrderItems(_ items: [[OrderItem]], forOrderId orderId: OrderSummary.ID) throws {
        
        var orderItemsByOrderId = self.orderItemsByOrderId
        
        orderItemsByOrderId[orderId] = items
        
        try setOrderItemsByOrderId(orderItemsByOrderId)
    }
    
    
    public var orderFeedbacksByOrderId: [OrderSummary.ID: [Feedback]] {
        
        data?.orderFeedbacksByOrderId ?? [:]
    }
    
    
    public func setOrderFeedbacksByOrderId(_ orderFeedbacksByOrderId: [OrderSummary.ID: [Feedback]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderFeedbacksByOrderId = orderFeedbacksByOrderId
    }
    
    
    public func setOrderFeedbacks(_ feedbacks: [Feedback], forOrderId orderId: OrderSummary.ID) throws {
        
        var orderFeedbacksByOrderId = self.orderFeedbacksByOrderId
        
        orderFeedbacksByOrderId[orderId] = feedbacks
        
        try setOrderFeedbacksByOrderId(orderFeedbacksByOrderId)
    }

    
    public var shippingCostsByOrderId: [OrderSummary.ID: Float] {
        
        data?.shippingCostsByOrderId ?? [:]
    }
    
    
    public func setShippingCostsByOrderId(_ shippingCostsByOrderId: [OrderSummary.ID: Float]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.shippingCostsByOrderId = shippingCostsByOrderId
    }
    
    
    public func setShippingCost(_ cost: Float, forOrderId orderId: OrderSummary.ID) throws {
        
        var shippingCostsByOrderId = self.shippingCostsByOrderId
        
        shippingCostsByOrderId[orderId] = cost
        
        try setShippingCostsByOrderId(shippingCostsByOrderId)
    }
    
    
    public var stampingMethodByOrderId: [OrderSummary.ID: String] {
        
        data?.stampingMethodByOrderId ?? [:]
    }
    
    
    public func setStampingMethodByOrderId(_ stampingMethodByOrderId: [OrderSummary.ID: String]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.stampingMethodByOrderId = stampingMethodByOrderId
    }
    
    
    public func setStampingMethod(_ method: String, forOrderId orderId: OrderSummary.ID) throws {
        
        var stampingMethodByOrderId = self.stampingMethodByOrderId
        
        stampingMethodByOrderId[orderId] = method
        
        try setStampingMethodByOrderId(stampingMethodByOrderId)
    }
    
    
    public var pickedItemIdsByOrderId: [OrderSummary.ID: [OrderItem.ID]] {
        
        data?.pickedItemIdsByOrderId ?? [:]
    }
    
    
    public func setPickedItemIdsByOrderId(_ pickedItemsByOrderId: [OrderSummary.ID: [OrderItem.ID]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.pickedItemIdsByOrderId = pickedItemsByOrderId
    }
    
    
    public func addPickedItemId(_ itemId: OrderItem.ID, toOrderWithId orderId: OrderSummary.ID) throws {
        
        var pickedItemsByOrderId = self.pickedItemIdsByOrderId
        var pickedItemsForOrder = pickedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        guard !pickedItemsForOrder.contains(itemId) else { return }
            
        pickedItemsForOrder.append(itemId)
        pickedItemsByOrderId[orderId] = pickedItemsForOrder
        
        try setPickedItemIdsByOrderId(pickedItemsByOrderId)
    }
    
    
    public func removePickedItemId(_ itemId: OrderItem.ID, fromOrderWithId orderId: OrderSummary.ID) throws {
        
        var pickedItemsByOrderId = self.pickedItemIdsByOrderId
        var pickedItemsForOrder = pickedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        pickedItemsForOrder.removeAll { $0 == itemId }
        pickedItemsByOrderId[orderId] = pickedItemsForOrder
        
        if pickedItemsByOrderId[orderId]!.isEmpty {
            pickedItemsByOrderId.removeValue(forKey: orderId)
        }
        
        try setPickedItemIdsByOrderId(pickedItemsByOrderId)
    }
    
    
    public var verifiedItemIdsByOrderId: [OrderSummary.ID: [OrderItem.ID]] {
        
        data?.verifiedItemIdsByOrderId ?? [:]
    }
    
    
    public func setVerifiedItemIdsByOrderId(_ verifiedItemsByOrderId: [OrderSummary.ID: [OrderItem.ID]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.verifiedItemIdsByOrderId = verifiedItemsByOrderId
    }
    
    
    public func addVerifiedItemId(_ itemId: OrderItem.ID, toOrderWithId orderId: OrderSummary.ID) throws {
        
        var verifiedItemsByOrderId = self.verifiedItemIdsByOrderId
        var verifiedItemsForOrder = verifiedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        guard !verifiedItemsForOrder.contains(itemId) else { return }
            
        verifiedItemsForOrder.append(itemId)
        verifiedItemsByOrderId[orderId] = verifiedItemsForOrder
        
        try setVerifiedItemIdsByOrderId(verifiedItemsByOrderId)
    }
    
    
    public func removeVerifiedItemId(_ itemId: OrderItem.ID, fromOrderWithId orderId: OrderSummary.ID) throws {
        
        var verifiedItemsByOrderId = self.verifiedItemIdsByOrderId
        var verifiedItemsForOrder = verifiedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        verifiedItemsForOrder.removeAll { $0 == itemId }
        verifiedItemsByOrderId[orderId] = verifiedItemsForOrder
        
        if verifiedItemsByOrderId[orderId]!.isEmpty {
            verifiedItemsByOrderId.removeValue(forKey: orderId)
        }
        
        try setVerifiedItemIdsByOrderId(verifiedItemsByOrderId)
    }
    
    
    public var dateValidatedWithoutIncomeTransactionByOrderId: [OrderSummary.ID: Date] {
        
        data?.dateValidatedWithoutIncomeTransactionByOrderId ?? [:]
    }
    
    
    public func setDateValidatedWithoutIncomeTransactionByOrderId(_ dateValidatedWithoutIncomeTransactionByOrderId: [OrderSummary.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutIncomeTransactionByOrderId = dateValidatedWithoutIncomeTransactionByOrderId
    }
    
    
    public func setDateValidatedWithoutIncomeTransaction(_ date: Date, forOrderId orderId: OrderSummary.ID) throws {
        
        var dateValidatedWithoutIncomeTransactionByOrderId = self.dateValidatedWithoutIncomeTransactionByOrderId
        
        dateValidatedWithoutIncomeTransactionByOrderId[orderId] = date
        
        try setDateValidatedWithoutIncomeTransactionByOrderId(dateValidatedWithoutIncomeTransactionByOrderId)
    }
    
    
    public var dateValidatedWithoutShippingTransactionByOrderId: [OrderSummary.ID: Date] {
        
        data?.dateValidatedWithoutShippingTransactionByOrderId ?? [:]
    }
    
    
    public func setDateValidatedWithoutShippingTransactionByOrderId(_ dateValidatedWithoutShippingTransactionByOrderId: [OrderSummary.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutShippingTransactionByOrderId = dateValidatedWithoutShippingTransactionByOrderId
    }
    
    
    public func setDateValidatedWithoutShippingTransaction(_ date: Date, forOrderId orderId: OrderSummary.ID) throws {
        
        var dateValidatedWithoutShippingTransactionByOrderId = self.dateValidatedWithoutShippingTransactionByOrderId
        
        dateValidatedWithoutShippingTransactionByOrderId[orderId] = date
        
        try setDateValidatedWithoutShippingTransactionByOrderId(dateValidatedWithoutShippingTransactionByOrderId)
    }
    
    
    public var dateValidatedWithoutStampingByOrderId: [OrderSummary.ID: Date] {
        
        data?.dateValidatedWithoutStampingByOrderId ?? [:]
    }
    
    
    public func setDateValidatedWithoutStampingByOrderId(_ dateValidatedWithoutStampingByOrderId: [OrderSummary.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutStampingByOrderId = dateValidatedWithoutStampingByOrderId
    }
    
    
    public func setDateValidatedWithoutStamping(_ date: Date, forOrderId orderId: OrderSummary.ID) throws {
        
        var dateValidatedWithoutStampingByOrderId = self.dateValidatedWithoutStampingByOrderId
        
        dateValidatedWithoutStampingByOrderId[orderId] = date
        
        try setDateValidatedWithoutStampingByOrderId(dateValidatedWithoutStampingByOrderId)
    }
    
    
    public var dateValidatedWithoutFeedbackByOrderId: [OrderSummary.ID: Date] {
        
        data?.dateValidatedWithoutFeedbackByOrderId ?? [:]
    }
    
    
    public func setDateValidatedWithoutFeedbackByOrderId(_ dateValidatedWithoutFeedbackByOrderId: [OrderSummary.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutFeedbackByOrderId = dateValidatedWithoutFeedbackByOrderId
    }
    
    
    public func setDateValidatedWithoutFeedback(_ date: Date, forOrderId orderId: OrderSummary.ID) throws {
        
        var dateValidatedWithoutFeedbackByOrderId = self.dateValidatedWithoutFeedbackByOrderId
        
        dateValidatedWithoutFeedbackByOrderId[orderId] = date
        
        try setDateValidatedWithoutFeedbackByOrderId(dateValidatedWithoutFeedbackByOrderId)
    }
    
    
    public var uploadItems: [UploadItem] {
        
        data?.uploadItems ?? []
    }
    
    
    public func setUploadItems(_ uploadItems: [UploadItem]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.uploadItems = uploadItems
    }
    
    
    public func addUploadItem(_ uploadItem: UploadItem) throws {
        
        var uploadItems = self.uploadItems
        
        uploadItems.append(uploadItem)
        
        try setUploadItems(uploadItems)
    }
    
    
    public func addUploadItems(_ uploadItems: [UploadItem]) throws {
        
        var uploadItems = self.uploadItems
        
        uploadItems.append(contentsOf: uploadItems)
        
        try setUploadItems(uploadItems)
    }
    
    
    public func deleteUploadItem(_ uploadItem: UploadItem) throws {
        
        var uploadItems = self.uploadItems
        
        uploadItems.removeAll(where: { $0.id == uploadItem.id })
        
        try setUploadItems(uploadItems)
    }
    
    
    public func updateUploadItem(_ updatedItem: UploadItem) throws {
        
        var uploadItems = self.uploadItems
        
        guard let idx = uploadItems.firstIndex(where: { $0.id == updatedItem.id }) else {
            fatalError("could not update upload item #\(updatedItem.id): item not found")
        }
        uploadItems[idx] = updatedItem
    
        try setUploadItems(uploadItems)
    }
    
    
    public var uploadedItems: [UploadedItem] {
        
        data?.uploadedItems ?? []
    }
    
    
    public func setUploadedItems(_ uploadedItems: [UploadedItem]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.uploadedItems = uploadedItems
    }
    
    
    public func addUploadedItem(_ uploadedItem: UploadedItem) throws {
        
        var uploadedItems = self.uploadedItems
        
        uploadedItems.append(uploadedItem)
        
        try setUploadedItems(uploadedItems)
    }
    
    
    public var transactions: [Transaction] {
        
        data?.transactions ?? []
    }
    
    
    public func setTransactions(_ transactions: [Transaction]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.transactions = transactions
    }
    
    
    public func addTransaction(_ transaction: Transaction) throws {
        
        var transactions = self.transactions
        
        transactions.append(transaction)
        
        try setTransactions(transactions)
    }
    
    
    public var orderRefunds: [OrderRefund] {
        
        data?.orderRefunds ?? []
    }
    
    
    public func setOrderRefunds(_ orderRefunds: [OrderRefund]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderRefunds = orderRefunds
    }
    
    
    public func addOrderRefund(_ refund: OrderRefund) throws {
        
        var orderRefunds = self.orderRefunds
        
        orderRefunds.append(refund)
        
        try setOrderRefunds(orderRefunds)
    }
    
    
    public var laPosteTrackingStatusByTrackingNo: [String: LaPosteTrackingStatus] {
        
        data?.laPosteTrackingStatusByTrackingNo ?? [:]
    }
    
    
    public func setLaPosteTrackingStatusByTrackingNo(_ laPosteTrackingStatusByTrackingNo: [String: LaPosteTrackingStatus]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.laPosteTrackingStatusByTrackingNo = laPosteTrackingStatusByTrackingNo
    }
    
    
    public func setLaPosteTrackingStatus(_ status: LaPosteTrackingStatus, forTrackingNo trackingNo: String) throws {
        
        var laPosteTrackingStatusByTrackingNo = self.laPosteTrackingStatusByTrackingNo
        
        laPosteTrackingStatusByTrackingNo[trackingNo] = status
        
        try setLaPosteTrackingStatusByTrackingNo(laPosteTrackingStatusByTrackingNo)
    }
}



struct DataRoot: Codable {
    
    var _meta: String?
    
    // MARK: - External data
    
    var colors: [LegoColor]?
    var inventories: [InventoryItem]?
    var orderSummaries: [OrderSummary]?
    var orderDetails: [OrderDetails]?
    var orderItemsByOrderId: [OrderSummary.ID: [[OrderItem]]]?
    var orderFeedbacksByOrderId: [OrderSummary.ID: [Feedback]]?
    
    // MARK: - Local data
    
    var shippingCostsByOrderId: [OrderSummary.ID: Float]?
    var stampingMethodByOrderId: [OrderSummary.ID: String]?
    var pickedItemIdsByOrderId: [OrderSummary.ID: [OrderItem.ID]]?
    var verifiedItemIdsByOrderId: [OrderSummary.ID: [OrderItem.ID]]?
    var dateValidatedWithoutIncomeTransactionByOrderId: [OrderSummary.ID: Date]?
    var dateValidatedWithoutShippingTransactionByOrderId: [OrderSummary.ID: Date]?
    var dateValidatedWithoutStampingByOrderId: [OrderSummary.ID: Date]?
    var dateValidatedWithoutFeedbackByOrderId: [OrderSummary.ID: Date]?
    var uploadItems: [UploadItem]?
    var uploadedItems: [UploadedItem]?
    var transactions: [Transaction]?
    var orderRefunds: [OrderRefund]?
    var laPosteTrackingStatusByTrackingNo: [String: LaPosteTrackingStatus]?
}
