
import Foundation



public struct OrderDetails: Identifiable, Equatable, Codable {
    
    public let id: String
    public let remarks: String?
    
    public let totalWeight: Float
    public let driveThruSent: Bool
    public let trackingNo: String?
    
    public let shippingMethodId: Int
    public let shippingMethodName: String?
    public let shippingAddress: String
    public let shippingAddressCountryCode: String
    public let shippingAddressName: String
    
    public let shippingCost: Float
    public let dispShippingCost: Float

    public var isShippedWithLaPoste: Bool { shippingMethodId.isOneOf(shippingMethodIds_LaPoste) }
}
