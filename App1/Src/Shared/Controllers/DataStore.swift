
import Foundation



class DataStore {
    
    
    private let dataFileUrl: URL
    
    private var data: DataFile? = nil
    
    
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
        
            let decodedData = try! decoder.decode(DataFile.self, from: rawData)
            self.data = decodedData
            
        } else {
            
            self.data = DataFile()
        }
    }
    
    
    private func write() throws {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let rawData = try encoder.encode(data)
        try rawData.write(to: self.dataFileUrl)
    }
    
    
    func save() throws {
        
        try write()
    }
    
    
    // MARK: - setters & getters
    
    
    var colors: [LegoColor] {
        
        data?.colors ?? []
    }
    
    
    func setColors(_ colors: [LegoColor]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.colors = colors
    }
    
    
    var inventories: [InventoryItem] {
        
        data?.inventories ?? []
    }
    
    
    func setInventories(_ inventories: [InventoryItem]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.inventories = inventories.sorted { $0.id < $1.id }
    }
    
    
    func setInventory(_ inventory: InventoryItem) throws {
        
        var inventories = self.inventories
        
        if let index = inventories.firstIndex(where: { $0.id == inventory.id }) {
            inventories[index] = inventory
        } else {
            inventories.append(inventory)
        }
        
        try setInventories(inventories)
    }
    
    
    var orderSummaries: [Order] {
        
        data?.orderSummaries ?? []
    }
    
    
    func setOrderSummaries(_ orderSummaries: [Order]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderSummaries = orderSummaries
    }
    
    
    var orderDetails: [OrderDetails] {
        
        data?.orderDetails ?? []
    }
    
    
    func setOrderDetails(_ orderDetails: [OrderDetails]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderDetails = orderDetails
    }
    
    
    func setOrderDetail(_ orderDetail: OrderDetails) throws {
        
        var orderDetails = self.orderDetails
        
        if let index = orderDetails.firstIndex(where: { $0.id == orderDetail.id }) {
            orderDetails[index] = orderDetail
        } else {
            orderDetails.append(orderDetail)
        }
        
        try setOrderDetails(orderDetails)
    }
    
    
    var orderItemsByOrderId: [Order.ID: [[OrderItem]]] {
        
        data?.orderItemsByOrderId ?? [:]
    }
    
    
    func setOrderItemsByOrderId(_ orderItemsByOrderId: [Order.ID: [[OrderItem]]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderItemsByOrderId = orderItemsByOrderId
    }
    
    
    func setOrderItems(_ items: [[OrderItem]], forOrderId orderId: Order.ID) throws {
        
        var orderItemsByOrderId = self.orderItemsByOrderId
        
        orderItemsByOrderId[orderId] = items
        
        try setOrderItemsByOrderId(orderItemsByOrderId)
    }
    
    
    var orderFeedbacksByOrderId: [Order.ID: [Feedback]] {
        
        data?.orderFeedbacksByOrderId ?? [:]
    }
    
    
    func setOrderFeedbacksByOrderId(_ orderFeedbacksByOrderId: [Order.ID: [Feedback]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderFeedbacksByOrderId = orderFeedbacksByOrderId
    }
    
    
    func setOrderFeedbacks(_ feedbacks: [Feedback], forOrderId orderId: Order.ID) throws {
        
        var orderFeedbacksByOrderId = self.orderFeedbacksByOrderId
        
        orderFeedbacksByOrderId[orderId] = feedbacks
        
        try setOrderFeedbacksByOrderId(orderFeedbacksByOrderId)
    }

    
    var shippingCostsByOrderId: [Order.ID: Float] {
        
        data?.shippingCostsByOrderId ?? [:]
    }
    
    
    func setShippingCostsByOrderId(_ shippingCostsByOrderId: [Order.ID: Float]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.shippingCostsByOrderId = shippingCostsByOrderId
    }
    
    
    func setShippingCost(_ cost: Float, forOrderId orderId: Order.ID) throws {
        
        var shippingCostsByOrderId = self.shippingCostsByOrderId
        
        shippingCostsByOrderId[orderId] = cost
        
        try setShippingCostsByOrderId(shippingCostsByOrderId)
    }
    
    
    var stampingMethodByOrderId: [Order.ID: String] {
        
        data?.stampingMethodByOrderId ?? [:]
    }
    
    
    func setStampingMethodByOrderId(_ stampingMethodByOrderId: [Order.ID: String]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.stampingMethodByOrderId = stampingMethodByOrderId
    }
    
    
    func setStampingMethod(_ method: String, forOrderId orderId: Order.ID) throws {
        
        var stampingMethodByOrderId = self.stampingMethodByOrderId
        
        stampingMethodByOrderId[orderId] = method
        
        try setStampingMethodByOrderId(stampingMethodByOrderId)
    }
    
    
    var pickedItemIdsByOrderId: [Order.ID: [OrderItem.ID]] {
        
        data?.pickedItemIdsByOrderId ?? [:]
    }
    
    
    func setPickedItemIdsByOrderId(_ pickedItemsByOrderId: [Order.ID: [OrderItem.ID]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.pickedItemIdsByOrderId = pickedItemsByOrderId
    }
    
    
    func addPickedItemId(_ itemId: OrderItem.ID, toOrderWithId orderId: Order.ID) throws {
        
        var pickedItemsByOrderId = self.pickedItemIdsByOrderId
        var pickedItemsForOrder = pickedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        guard !pickedItemsForOrder.contains(itemId) else { return }
            
        pickedItemsForOrder.append(itemId)
        pickedItemsByOrderId[orderId] = pickedItemsForOrder
        
        try setPickedItemIdsByOrderId(pickedItemsByOrderId)
    }
    
    
    func removePickedItemId(_ itemId: OrderItem.ID, fromOrderWithId orderId: Order.ID) throws {
        
        var pickedItemsByOrderId = self.pickedItemIdsByOrderId
        var pickedItemsForOrder = pickedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        pickedItemsForOrder.removeAll { $0 == itemId }
        pickedItemsByOrderId[orderId] = pickedItemsForOrder
        
        if pickedItemsByOrderId[orderId]!.isEmpty {
            pickedItemsByOrderId.removeValue(forKey: orderId)
        }
        
        try setPickedItemIdsByOrderId(pickedItemsByOrderId)
    }
    
    
    var verifiedItemIdsByOrderId: [Order.ID: [OrderItem.ID]] {
        
        data?.verifiedItemIdsByOrderId ?? [:]
    }
    
    
    func setVerifiedItemIdsByOrderId(_ verifiedItemsByOrderId: [Order.ID: [OrderItem.ID]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.verifiedItemIdsByOrderId = verifiedItemsByOrderId
    }
    
    
    func addVerifiedItemId(_ itemId: OrderItem.ID, toOrderWithId orderId: Order.ID) throws {
        
        var verifiedItemsByOrderId = self.verifiedItemIdsByOrderId
        var verifiedItemsForOrder = verifiedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        guard !verifiedItemsForOrder.contains(itemId) else { return }
            
        verifiedItemsForOrder.append(itemId)
        verifiedItemsByOrderId[orderId] = verifiedItemsForOrder
        
        try setVerifiedItemIdsByOrderId(verifiedItemsByOrderId)
    }
    
    
    func removeVerifiedItemId(_ itemId: OrderItem.ID, fromOrderWithId orderId: Order.ID) throws {
        
        var verifiedItemsByOrderId = self.verifiedItemIdsByOrderId
        var verifiedItemsForOrder = verifiedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        verifiedItemsForOrder.removeAll { $0 == itemId }
        verifiedItemsByOrderId[orderId] = verifiedItemsForOrder
        
        if verifiedItemsByOrderId[orderId]!.isEmpty {
            verifiedItemsByOrderId.removeValue(forKey: orderId)
        }
        
        try setVerifiedItemIdsByOrderId(verifiedItemsByOrderId)
    }
    
    
    var dateValidatedWithoutIncomeTransactionByOrderId: [Order.ID: Date] {
        
        data?.dateValidatedWithoutIncomeTransactionByOrderId ?? [:]
    }
    
    
    func setDateValidatedWithoutIncomeTransactionByOrderId(_ dateValidatedWithoutIncomeTransactionByOrderId: [Order.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutIncomeTransactionByOrderId = dateValidatedWithoutIncomeTransactionByOrderId
    }
    
    
    func setDateValidatedWithoutIncomeTransaction(_ date: Date, forOrderId orderId: Order.ID) throws {
        
        var dateValidatedWithoutIncomeTransactionByOrderId = self.dateValidatedWithoutIncomeTransactionByOrderId
        
        dateValidatedWithoutIncomeTransactionByOrderId[orderId] = date
        
        try setDateValidatedWithoutIncomeTransactionByOrderId(dateValidatedWithoutIncomeTransactionByOrderId)
    }
    
    
    var dateValidatedWithoutShippingTransactionByOrderId: [Order.ID: Date] {
        
        data?.dateValidatedWithoutShippingTransactionByOrderId ?? [:]
    }
    
    
    func setDateValidatedWithoutShippingTransactionByOrderId(_ dateValidatedWithoutShippingTransactionByOrderId: [Order.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutShippingTransactionByOrderId = dateValidatedWithoutShippingTransactionByOrderId
    }
    
    
    func setDateValidatedWithoutShippingTransaction(_ date: Date, forOrderId orderId: Order.ID) throws {
        
        var dateValidatedWithoutShippingTransactionByOrderId = self.dateValidatedWithoutShippingTransactionByOrderId
        
        dateValidatedWithoutShippingTransactionByOrderId[orderId] = date
        
        try setDateValidatedWithoutShippingTransactionByOrderId(dateValidatedWithoutShippingTransactionByOrderId)
    }
    
    
    var dateValidatedWithoutStampingByOrderId: [Order.ID: Date] {
        
        data?.dateValidatedWithoutStampingByOrderId ?? [:]
    }
    
    
    func setDateValidatedWithoutStampingByOrderId(_ dateValidatedWithoutStampingByOrderId: [Order.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutStampingByOrderId = dateValidatedWithoutStampingByOrderId
    }
    
    
    func setDateValidatedWithoutStamping(_ date: Date, forOrderId orderId: Order.ID) throws {
        
        var dateValidatedWithoutStampingByOrderId = self.dateValidatedWithoutStampingByOrderId
        
        dateValidatedWithoutStampingByOrderId[orderId] = date
        
        try setDateValidatedWithoutStampingByOrderId(dateValidatedWithoutStampingByOrderId)
    }
    
    
    var dateValidatedWithoutFeedbackByOrderId: [Order.ID: Date] {
        
        data?.dateValidatedWithoutFeedbackByOrderId ?? [:]
    }
    
    
    func setDateValidatedWithoutFeedbackByOrderId(_ dateValidatedWithoutFeedbackByOrderId: [Order.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutFeedbackByOrderId = dateValidatedWithoutFeedbackByOrderId
    }
    
    
    func setDateValidatedWithoutFeedback(_ date: Date, forOrderId orderId: Order.ID) throws {
        
        var dateValidatedWithoutFeedbackByOrderId = self.dateValidatedWithoutFeedbackByOrderId
        
        dateValidatedWithoutFeedbackByOrderId[orderId] = date
        
        try setDateValidatedWithoutFeedbackByOrderId(dateValidatedWithoutFeedbackByOrderId)
    }
    
    
    var uploadItems: [UploadItem] {
        
        data?.uploadItems ?? []
    }
    
    
    func setUploadItems(_ uploadItems: [UploadItem]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.uploadItems = uploadItems
    }
    
    
    func addUploadItem(_ uploadItem: UploadItem) throws {
        
        var uploadItems = self.uploadItems
        
        uploadItems.append(uploadItem)
        
        try setUploadItems(uploadItems)
    }
    
    
    func addUploadItems(_ addedUploadItems: [UploadItem]) throws {
        
        var newUploadItems = self.uploadItems
        
        newUploadItems.append(contentsOf: addedUploadItems)
        
        try setUploadItems(newUploadItems)
    }
    
    
    func deleteUploadItem(_ uploadItem: UploadItem) throws {
        
        var uploadItems = self.uploadItems
        
        uploadItems.removeAll(where: { $0.id == uploadItem.id })
        
        try setUploadItems(uploadItems)
    }
    
    
    func updateUploadItem(_ updatedItem: UploadItem) throws {
        
        var uploadItems = self.uploadItems
        
        guard let idx = uploadItems.firstIndex(where: { $0.id == updatedItem.id }) else {
            fatalError("could not update upload item #\(updatedItem.id): item not found")
        }
        uploadItems[idx] = updatedItem
    
        try setUploadItems(uploadItems)
    }
    
    
    var uploadedItems: [UploadedItem] {
        
        data?.uploadedItems ?? []
    }
    
    
    func setUploadedItems(_ uploadedItems: [UploadedItem]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.uploadedItems = uploadedItems
    }
    
    
    func addUploadedItem(_ uploadedItem: UploadedItem) throws {
        
        var uploadedItems = self.uploadedItems
        
        uploadedItems.append(uploadedItem)
        
        try setUploadedItems(uploadedItems)
    }
    
    
    var transactions: [Transaction] {
        
        data?.transactions ?? []
    }
    
    
    func setTransactions(_ transactions: [Transaction]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.transactions = transactions
    }
    
    
    func addTransaction(_ transaction: Transaction) throws {
        
        var transactions = self.transactions
        
        transactions.append(transaction)
        
        try setTransactions(transactions)
    }
    
    
    var allRefunds: [OrderRefund] {
        
        data?.orderRefunds ?? []
    }
    
    
    func setOrderRefunds(_ orderRefunds: [OrderRefund]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderRefunds = orderRefunds
    }
    
    
    func addOrderRefund(_ refund: OrderRefund) throws {
        
        var orderRefunds = self.allRefunds
        
        orderRefunds.append(refund)
        
        try setOrderRefunds(orderRefunds)
    }
    
    
    var laPosteTrackingStatusByTrackingNo: [TrackingNo: LaPosteTrackingStatus] {
        
        data?.laPosteTrackingStatusByTrackingNo ?? [:]
    }
    
    
    func setLaPosteTrackingStatusByTrackingNo(_ laPosteTrackingStatusByTrackingNo: [TrackingNo: LaPosteTrackingStatus]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.laPosteTrackingStatusByTrackingNo = laPosteTrackingStatusByTrackingNo
    }
    
    
    func setLaPosteTrackingStatus(_ status: LaPosteTrackingStatus, forTrackingNo trackingNo: TrackingNo) throws {
        
        var laPosteTrackingStatusByTrackingNo = self.laPosteTrackingStatusByTrackingNo
        
        laPosteTrackingStatusByTrackingNo[trackingNo] = status
        
        try setLaPosteTrackingStatusByTrackingNo(laPosteTrackingStatusByTrackingNo)
    }
}



@Observable
class DataFile: Codable {
    
    @ObservationIgnored
    var _meta: String?
    
    // MARK: - External data
    
    var colors: [LegoColor]?
    var inventories: [InventoryItem]?
    var orderSummaries: [Order]?
    var orderDetails: [OrderDetails]?
    var orderItemsByOrderId: [Order.ID: [[OrderItem]]]?
    var orderFeedbacksByOrderId: [Order.ID: [Feedback]]?
    
    // MARK: - Local data
    
    var shippingCostsByOrderId: [Order.ID: Float]?
    var stampingMethodByOrderId: [Order.ID: String]?
    var pickedItemIdsByOrderId: [Order.ID: [OrderItem.ID]]?
    var verifiedItemIdsByOrderId: [Order.ID: [OrderItem.ID]]?
    var dateValidatedWithoutIncomeTransactionByOrderId: [Order.ID: Date]?
    var dateValidatedWithoutShippingTransactionByOrderId: [Order.ID: Date]?
    var dateValidatedWithoutStampingByOrderId: [Order.ID: Date]?
    var dateValidatedWithoutFeedbackByOrderId: [Order.ID: Date]?
    var uploadItems: [UploadItem]?
    var uploadedItems: [UploadedItem]?
    var transactions: [Transaction]?
    var orderRefunds: [OrderRefund]?
    var laPosteTrackingStatusByTrackingNo: [TrackingNo: LaPosteTrackingStatus]?
    
    
    enum CodingKeys: String, CodingKey {
        case _meta = "_meta"
        case _colors = "colors"
        case _inventories = "inventories"
        case _orderSummaries = "orderSummaries"
        case _orderDetails = "orderDetails"
        case _orderItemsByOrderId = "orderItemsByOrderId"
        case _orderFeedbacksByOrderId = "orderFeedbacksByOrderId"
        case _shippingCostsByOrderId = "shippingCostsByOrderId"
        case _stampingMethodByOrderId = "stampingMethodByOrderId"
        case _pickedItemIdsByOrderId = "pickedItemIdsByOrderId"
        case _verifiedItemIdsByOrderId = "verifiedItemIdsByOrderId"
        case _dateValidatedWithoutIncomeTransactionByOrderId = "dateValidatedWithoutIncomeTransactionByOrderId"
        case _dateValidatedWithoutShippingTransactionByOrderId = "dateValidatedWithoutShippingTransactionByOrderId"
        case _dateValidatedWithoutStampingByOrderId = "dateValidatedWithoutStampingByOrderId"
        case _dateValidatedWithoutFeedbackByOrderId = "dateValidatedWithoutFeedbackByOrderId"
        case _uploadItems = "uploadItems"
        case _uploadedItems = "uploadedItems"
        case _transactions = "transactions"
        case _orderRefunds = "orderRefunds"
        case _laPosteTrackingStatusByTrackingNo = "laPosteTrackingStatusByTrackingNo"
    }
}
