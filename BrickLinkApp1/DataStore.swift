
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
    
    
    public var shippingCostsByOrderId: [String: Int] {
        
        data?.shippingCostsByOrderId ?? [:]
    }
    
    
    public func setShippingCostsByOrderId(_ shippingCostsByOrderId: [String: Int]) throws {
        
        guard data != nil else { throw "Attempted to mutate data before it is loaded" }
        
        data!.shippingCostsByOrderId = shippingCostsByOrderId
    }
    
    
    public func save() throws {
        
        try write()
    }
}


struct DataRoot: Codable {
    
    var shippingCostsByOrderId: [String: Int]
}


extension String: Error { }
