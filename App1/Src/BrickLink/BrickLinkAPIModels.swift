
import Foundation



struct BrickLinkAPIResponse<T>: Decodable where T: Decodable {
    
    let data: T?
}



struct BrickLinkOrderSummary: Decodable {
    
    let orderId: Int
    let dateOrdered: Date
    let dateStatusChanged: Date
    let buyerName: String
    let status: String
    let totalCount: Int
    let uniqueCount: Int
    let payment: BrickLinkOrderPayment
    let cost: BrickLinkOrderCost
    let dispCost: BrickLinkOrderCost
}



struct BrickLinkOrderDetails: Decodable {
    
    let orderId: Int
    let dateOrdered: Date
    let dateStatusChanged: Date
    let buyerName: String
    let status: String
    let remarks: String?
    let totalCount: Int
    let uniqueCount: Int
    let totalWeight: FixedPointNumber?
    let driveThruSent: Bool?
    let payment: BrickLinkOrderPayment
    let shipping: BrickLinkOrderShipping?
    let cost: BrickLinkOrderCost
    let dispCost: BrickLinkOrderCost
}



struct BrickLinkOrderPayment: Decodable {
    
    let status: String
}



struct BrickLinkOrderShipping: Decodable {
    
    let methodId: Int
    let method: String?
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
    let item: BrickLinkCatalogItem
    let quantity: Int
    let colorId: Int
    let colorName: String
    let newOrUsed: BrickLinkItemCondition
    let remarks: String?
    let description: String?
    let unitPrice: FixedPointNumber
    let unitPriceFinal: FixedPointNumber
}



struct BrickLinkOrderFeedback: Decodable {
    
    let feedbackId: Int
    let orderId: Int
    let from: String
    let to: String
    let dateRated: Date
    let rating: BrickLinkFeedbackRating
    let ratingOfBs: BrickLinkFeedbackRatingOfBS
    let comment: String
}



enum BrickLinkFeedbackRating: Int, Decodable, Encodable {
    
    case praise = 0
    case neutral = 1
    case complaint = 2
}



enum BrickLinkFeedbackRatingOfBS: String, Decodable, Encodable {
    
    case forBuyer = "B"
    case forSeller = "S"
}



struct BrickLinkCatalogItem: Decodable {

    let no: String
    let name: String
    let type: BrickLinkItemType
}



enum BrickLinkItemType: String, Decodable, Encodable, CaseIterable {
    
    case part = "PART"
    case minifig = "MINIFIG"
}



enum BrickLinkItemCondition: String, Decodable, Encodable, CaseIterable {
    
    case new = "N"
    case used = "U"
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


struct BrickLinkInventoryItem: Decodable {
    
    let inventoryId: Int
    let item: BrickLinkCatalogItem
    let colorId: Int
    let quantity: Int
    let newOrUsed: BrickLinkItemCondition
    let description: String?
    let remarks: String?
    let unitPrice: FixedPointNumber
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
