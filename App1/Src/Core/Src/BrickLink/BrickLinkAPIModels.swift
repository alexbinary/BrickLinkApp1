
import Foundation



public struct BrickLinkAPIResponse<T>: Decodable where T: Decodable {
    
    public let data: T?
}



public struct BrickLinkOrder: Decodable {
    
    // MARK: Summary
    
    public let orderId: Int
    public let dateOrdered: Date
    public let buyerName: String
    public let totalCount: Int
    public let uniqueCount: Int
    public let cost: BrickLinkOrderCost
    public let dispCost: BrickLinkOrderCost
    public let status: String
    public let dateStatusChanged: Date
    public let payment: BrickLinkOrderPayment
    public let remarks: String?
    
    // MARK: Details
    
    public let driveThruSent: Bool?
    public let shipping: BrickLinkOrderShipping?
    public let totalWeight: FixedPointNumber?
}



public struct BrickLinkOrderPayment: Decodable {
    
    public let status: String
}



public struct BrickLinkOrderShipping: Decodable {
    
    public let methodId: Int
    public let method: String?
    public let trackingNo: String?
    public let address: BrickLinkOrderShippingAddress
}



public struct BrickLinkOrderShippingAddress: Decodable {
    
    public let countryCode: String
    public let full: String
    public let name: BrickLinkOrderShippingAddressName
}



public struct BrickLinkOrderShippingAddressName: Decodable {
    
    public let full: String
}



public struct BrickLinkOrderItem: Decodable {
    
    public let inventoryId: Int
    public let item: BrickLinkCatalogItem
    public let quantity: Int
    public let colorId: Int
    public let colorName: String
    public let newOrUsed: String
    public let remarks: String?
    public let description: String?
    public let unitPrice: FixedPointNumber
    public let unitPriceFinal: FixedPointNumber
}



public struct BrickLinkOrderFeedback: Decodable {
    
    public let feedbackId: Int
    public let orderId: Int
    public let from: String
    public let to: String
    public let dateRated: Date
    public let rating: BrickLinkFeedbackRating
    public let ratingOfBs: BrickLinkFeedbackRatingOfBS
    public let comment: String
}



public enum BrickLinkFeedbackRating: Int, Decodable, Encodable {
    
    case praise = 0
    case neutral = 1
    case complaint = 2
}



public enum BrickLinkFeedbackRatingOfBS: String, Decodable, Encodable {
    
    case forBuyer = "B"
    case forSeller = "S"
}



public struct BrickLinkCatalogItem: Decodable {

    public let no: String
    public let name: String
    public let type: BrickLinkItemType
}



public enum BrickLinkItemType: String, Decodable, Encodable, CaseIterable, Sendable {
    
    case part = "PART"
    case minifig = "MINIFIG"
}



public struct BrickLinkOrderCost: Decodable {
    
    public let currencyCode: String
    public let subtotal: FixedPointNumber
    public let grandTotal: FixedPointNumber
    public let shipping: FixedPointNumber?
}



public struct BrickLinkColor: Decodable {
    
    public let colorId: Int
    public let colorName: String
    public let colorCode: String
}


public struct BrickLinkInventoryItem: Decodable {
    
    public let inventoryId: Int
    public let item: BrickLinkCatalogItem
    public let colorId: Int
    public let quantity: Int
    public let newOrUsed: String
    public let description: String?
    public let remarks: String?
    public let unitPrice: FixedPointNumber
}



public struct FixedPointNumber: Codable, ExpressibleByFloatLiteral, CustomStringConvertible {
    
    
    public typealias FloatLiteralType = Float
    
    
    public init(floatLiteral value: FloatLiteralType) {
    
        self.floatValue = value
    }
    
    
    public init(_ float: Float) {
    
        self.floatValue = float
    }
    
    
    public var floatValue: Float
    
    
    public init(from decoder: Decoder) throws {
        
        let stringValue = try! decoder.singleValueContainer().decode(String.self)
        self.floatValue = Float(stringValue)!
    }
    
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        try! container.encode(self.floatValue)
    }
    
    
    public var description: String { "\(floatValue)" }
}
