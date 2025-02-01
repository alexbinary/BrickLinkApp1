
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
    
    
    public var orderItemsByOrderId: [OrderSummary.ID: [[OrderItem]]] {
        
        data?.orderItemsByOrderId ?? [:]
    }
    
    
    public func setOrderItemsByOrderId(_ orderItemsByOrderId: [OrderSummary.ID: [[OrderItem]]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderItemsByOrderId = orderItemsByOrderId
    }
    
    
    public var orderFeedbacksByOrderId: [OrderSummary.ID: [Feedback]] {
        
        data?.orderFeedbacksByOrderId ?? [:]
    }
    
    
    public func setOrderFeedbacksByOrderId(_ orderFeedbacksByOrderId: [OrderSummary.ID: [Feedback]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderFeedbacksByOrderId = orderFeedbacksByOrderId
    }

    
    public var shippingCostsByOrderId: [OrderSummary.ID: Float] {
        
        data?.shippingCostsByOrderId ?? [:]
    }
    
    
    public func setShippingCostsByOrderId(_ shippingCostsByOrderId: [OrderSummary.ID: Float]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.shippingCostsByOrderId = shippingCostsByOrderId
    }
    
    
    public var stampingMethodByOrderId: [OrderSummary.ID: String] {
        
        data?.stampingMethodByOrderId ?? [:]
    }
    
    
    public func setStampingMethodByOrderId(_ stampingMethodByOrderId: [OrderSummary.ID: String]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.stampingMethodByOrderId = stampingMethodByOrderId
    }
    
    
    public var pickedItemsByOrderId: [OrderSummary.ID: [OrderItem.ID]] {
        
        data?.pickedItemsByOrderId ?? [:]
    }
    
    
    public func setPickedItemsByOrderId(_ pickedItemsByOrderId: [OrderSummary.ID: [OrderItem.ID]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.pickedItemsByOrderId = pickedItemsByOrderId
    }
    
    
    public var verifiedItemsByOrderId: [OrderSummary.ID: [OrderItem.ID]] {
        
        data?.verifiedItemsByOrderId ?? [:]
    }
    
    
    public func setVerifiedItemsByOrderId(_ verifiedItemsByOrderId: [OrderSummary.ID: [OrderItem.ID]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.verifiedItemsByOrderId = verifiedItemsByOrderId
    }
    
    
    public var dateValidatedWithoutIncomeTransactionByOrderId: [OrderSummary.ID: Date] {
        
        data?.dateValidatedWithoutIncomeTransactionByOrderId ?? [:]
    }
    
    
    public func setDateValidatedWithoutIncomeTransactionByOrderId(_ dateValidatedWithoutIncomeTransactionByOrderId: [OrderSummary.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutIncomeTransactionByOrderId = dateValidatedWithoutIncomeTransactionByOrderId
    }
    
    
    public var dateValidatedWithoutShippingTransactionByOrderId: [OrderSummary.ID: Date] {
        
        data?.dateValidatedWithoutShippingTransactionByOrderId ?? [:]
    }
    
    
    public func setDateValidatedWithoutShippingTransactionByOrderId(_ dateValidatedWithoutShippingTransactionByOrderId: [OrderSummary.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutShippingTransactionByOrderId = dateValidatedWithoutShippingTransactionByOrderId
    }
    
    
    public var dateValidatedWithoutStampingByOrderId: [OrderSummary.ID: Date] {
        
        data?.dateValidatedWithoutStampingByOrderId ?? [:]
    }
    
    
    public func setDateValidatedWithoutStampingByOrderId(_ dateValidatedWithoutStampingByOrderId: [OrderSummary.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutStampingByOrderId = dateValidatedWithoutStampingByOrderId
    }
    
    
    public var dateValidatedWithoutFeedbackByOrderId: [OrderSummary.ID: Date] {
        
        data?.dateValidatedWithoutFeedbackByOrderId ?? [:]
    }
    
    
    public func setDateValidatedWithoutFeedbackByOrderId(_ dateValidatedWithoutFeedbackByOrderId: [OrderSummary.ID: Date]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.dateValidatedWithoutFeedbackByOrderId = dateValidatedWithoutFeedbackByOrderId
    }
    
    
    public var uploadItems: [UploadItem] {
        
        data?.uploadItems ?? []
    }
    
    
    public func setUploadItems(_ uploadItems: [UploadItem]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.uploadItems = uploadItems
    }
    
    
    public var uploadedItems: [UploadedItem] {
        
        data?.uploadedItems ?? []
    }
    
    
    public func setUploadedItems(_ uploadedItems: [UploadedItem]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.uploadedItems = uploadedItems
    }
    
    
    public var transactions: [Transaction] {
        
        data?.transactions ?? []
    }
    
    
    public func setTransactions(_ transactions: [Transaction]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.transactions = transactions
    }
    
    
    public var orderRefunds: [OrderRefund] {
        
        data?.orderRefunds ?? []
    }
    
    
    public func setOrderRefunds(_ orderRefunds: [OrderRefund]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderRefunds = orderRefunds
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
    var pickedItemsByOrderId: [OrderSummary.ID: [OrderItem.ID]]?
    var verifiedItemsByOrderId: [OrderSummary.ID: [OrderItem.ID]]?
    var dateValidatedWithoutIncomeTransactionByOrderId: [OrderSummary.ID: Date]?
    var dateValidatedWithoutShippingTransactionByOrderId: [OrderSummary.ID: Date]?
    var dateValidatedWithoutStampingByOrderId: [OrderSummary.ID: Date]?
    var dateValidatedWithoutFeedbackByOrderId: [OrderSummary.ID: Date]?
    var uploadItems: [UploadItem]?
    var uploadedItems: [UploadedItem]?
    var transactions: [Transaction]?
    var orderRefunds: [OrderRefund]?
}
