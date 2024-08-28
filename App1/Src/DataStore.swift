
import Foundation



class DataStore {
    
    
    private let dataFileUrl: URL
    
    private var data: DataRoot? = nil
    
    
    init(dataFileUrl: URL) {
        
        print("Init data store with file \(dataFileUrl)")
        
        self.dataFileUrl = dataFileUrl
        
        try! loadDataFromFile()
    }
    
    
    private func loadDataFromFile() throws {
            
        let rawData = try Data(contentsOf: dataFileUrl)
        
        let decoder = JSONDecoder()
        decoder.allowsJSON5 = true
        
        self.data = try decoder.decode(DataRoot.self, from: rawData)
    }
    
    
    private func write() throws {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let rawData = try encoder.encode(data)
        try rawData.write(to: self.dataFileUrl)
    }
    
    
    public var shippingCostsByOrderId: [OrderId: Float] {
        
        data?.shippingCostsByOrderId ?? [:]
    }
    
    
    public var pickedItemsByOrderId: [OrderId: [InventoryId]] {
        
        data?.pickedItemsByOrderId ?? [:]
    }
    
    
    public func setShippingCostsByOrderId(_ shippingCostsByOrderId: [OrderId: Float]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.shippingCostsByOrderId = shippingCostsByOrderId
    }
    
    
    public func setPickedItemsByOrderId(_ pickedItemsByOrderId: [OrderId: [InventoryId]]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.pickedItemsByOrderId = pickedItemsByOrderId
    }
    
    
    public func save() throws {
        
        try write()
    }
}


typealias OrderId = String
typealias InventoryId = String


struct DataRoot: Codable {
    
    var shippingCostsByOrderId: [OrderId: Float]
    var pickedItemsByOrderId: [OrderId: [InventoryId]]
}


extension String: Error { }
