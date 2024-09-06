
import Foundation



struct BrickLinkAPIResponse<T>: Decodable where T: Decodable {
    
    let data: T?
}



struct BrickLinkOrderFeedback: Decodable {
    
    let feedbackId: Int
    let from: String
    let to: String
    let dateRated: Date
    let rating: Int
    let ratingOfBs: String
    let comment: String
}



struct BrickLinkOrder: Decodable {
    
    // MARK: Summary
    
    let orderId: Int
    let dateOrdered: Date
    let buyerName: String
    let totalCount: Int
    let uniqueCount: Int
    let cost: BrickLinkOrderCost
    let dispCost: BrickLinkOrderCost
    let status: String
    
    // MARK: Details
    
    let driveThruSent: Bool?
    let shipping: BrickLinkOrderShipping?
    let totalWeight: FixedPointNumber?
}



struct BrickLinkOrderShipping: Decodable {
    
    let methodId: Int
    let method: String
    let trackingNo: String?
    let address: BrickLinkOrderShippingAddress
}



struct BrickLinkOrderShippingAddress: Decodable {
    
    let countryCode: String
    let full: String
    let name: BrickLinkOrderShippingAddressName
}



struct BrickLinkOrderShippingAddressName: Decodable {
    
    let full: String
}



struct BrickLinkOrderItem: Decodable {
    
    let inventoryId: Int
    let item: BrickLinkInventoryItem
    let quantity: Int
    let colorId: Int
    let colorName: String
    let newOrUsed: String
    let remarks: String?
    let description: String?
    let unitPrice: FixedPointNumber
    let unitPriceFinal: FixedPointNumber
}



struct BrickLinkInventoryItem: Decodable {

    let no: String
    let name: String
    let type: BrickLinkItemType
}



enum BrickLinkItemType: String, Decodable {
    
    case part = "PART"
    case minifig = "MINIFIG"
}



struct BrickLinkOrderCost: Decodable {
    
    let currencyCode: String
    let subtotal: FixedPointNumber
    let grandTotal: FixedPointNumber
    let shipping: FixedPointNumber?
}



struct BrickLinkColor: Decodable {
    
    let colorId: Int
    let colorName: String
    let colorCode: String
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
