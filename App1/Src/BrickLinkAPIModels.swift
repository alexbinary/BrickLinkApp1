
import Foundation



struct BrickLinkAPIResponse<T>: Decodable where T: Decodable {
    
    let data: T?
}



struct BrickLinkOrder: Decodable {
    
    let orderId: Int
    let dateOrdered: Date
    let buyerName: String
    let totalCount: Int
    let uniqueCount: Int
    let cost: BrickLinkOrderCost
    let status: String
    let driveThruSent: Bool?
    let shipping: BrickLinkOrderShipping?
    let totalWeight: FixedPointNumber?
}



struct BrickLinkOrderShipping: Decodable {
    
    let trackingNo: String?
}



struct BrickLinkOrderItem: Decodable {
    
    let inventoryId: Int
    let item: BrickLinkInventoryItem
    let quantity: Int
    let colorId: Int
    let newOrUsed: String
    let remarks: String
    let description: String?
}



struct BrickLinkInventoryItem: Decodable {

    let no: String
    let name: String
}



struct BrickLinkOrderCost: Decodable {
    
    let grandTotal: FixedPointNumber
}



struct FixedPointNumber: Codable, ExpressibleByFloatLiteral, CustomStringConvertible {
    
    
    typealias FloatLiteralType = Float
    
    
    init(floatLiteral value: FloatLiteralType) {
    
        self.floatValue = value
    }
    
    
    init(_ float: Float) {
    
        self.floatValue = float
    }
    
    
    var floatValue: Float
    
    
    init(from decoder: Decoder) throws {
        
        let stringValue = try! decoder.singleValueContainer().decode(String.self)
        self.floatValue = Float(stringValue)!
    }
    
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        try! container.encode(self.floatValue)
    }
    
    
    var description: String { "\(floatValue)" }
}
