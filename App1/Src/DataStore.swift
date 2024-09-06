
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
            
        let rawData = try Data(contentsOf: dataFileUrl)
        
        let decoder = JSONDecoder()
        decoder.allowsJSON5 = true
        decoder.dateDecodingStrategy = .iso8601
        
        self.data = try decoder.decode(DataRoot.self, from: rawData)
    }
    
    
    private func write() throws {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let rawData = try encoder.encode(data)
        try rawData.write(to: self.dataFileUrl)
    }
    
    
    public var colors: [LegoColor] {
        
        data?.colors ?? []
    }
    
    
    public func setColors(_ colors: [LegoColor]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.colors = colors
    }
    
    
    public var orderSummaries: [OrderSummary] {
        
        data?.orderSummaries ?? []
    }
    
    
    public func setOrderSummaries(_ orderSummaries: [OrderSummary]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.orderSummaries = orderSummaries
    }

    
    public var shippingCostsByOrderId: [OrderId: Float] {
        
        data?.shippingCostsByOrderId ?? [:]
    }
    
    
    public func setShippingCostsByOrderId(_ shippingCostsByOrderId: [OrderId: Float]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.shippingCostsByOrderId = shippingCostsByOrderId
    }
    
    
    public var affranchissementMethodByOrderId: [OrderId: String] {
        
        data?.affranchissementMethodByOrderId ?? [:]
    }
    
    
    public func setAffranchissementMethodByOrderId(_ affranchissementMethodByOrderId: [OrderId: String]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.affranchissementMethodByOrderId = affranchissementMethodByOrderId
    }
    
    
    public var pickedItemsByOrderId: [OrderId: [InventoryId]] {
        
        data?.pickedItemsByOrderId ?? [:]
    }
    
    
    public func setPickedItemsByOrderId(_ pickedItemsByOrderId: [OrderId: [InventoryId]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.pickedItemsByOrderId = pickedItemsByOrderId
    }
    
    
    public var verifiedItemsByOrderId: [OrderId: [InventoryId]] {
        
        data?.verifiedItemsByOrderId ?? [:]
    }
    
    
    public func setVerifiedItemsByOrderId(_ verifiedItemsByOrderId: [OrderId: [InventoryId]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.verifiedItemsByOrderId = verifiedItemsByOrderId
    }
    
    
    public var transactions: [Transaction] {
        
        data?.transactions ?? []
    }
    
    
    public func setTransactions(_ transactions: [Transaction]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.transactions = transactions
    }
    
    
    public func save() throws {
        
        try write()
    }
}


typealias OrderId = String
typealias InventoryId = String


struct DataRoot: Codable {
    
    // MARK: - External data
    
    var colors: [LegoColor]
    var orderSummaries: [OrderSummary]
    
    // MARK: - Local data
    
    var shippingCostsByOrderId: [OrderId: Float]
    var affranchissementMethodByOrderId: [OrderId: String]
    var pickedItemsByOrderId: [OrderId: [InventoryId]]
    var verifiedItemsByOrderId: [OrderId: [InventoryId]]
    var transactions: [Transaction]
}


extension String: Error { }
