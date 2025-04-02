
import Foundation



public struct OrderDetails: Identifiable, Equatable, Codable {
    
    
    public let id: String
    public let remarks: String?
    
    public let totalWeight: Float
    public let driveThruSent: Bool
    public let trackingNo: TrackingNo?
    
    public let shippingMethodId: Int
    public let shippingMethodName: String?
    public let shippingAddress: String
    public let shippingAddressCountryCode: String
    public let shippingAddressName: String
    
    public let shippingCost: Float
    public let dispShippingCost: Float
    
    public var shipsToFrance: Bool { shippingMethodId.isOneOf(shippingMethodIds_France) }
    public var shipsWithLaPoste: Bool { shippingMethodId.isOneOf(shippingMethodIds_LaPoste) }
    public var shipsWithMondialRelay: Bool { shippingMethodId.isOneOf(shippingMethodIds_MondialRelay) }
}



extension OrderDetails {

    
    init(fromBl bl: BrickLinkOrderDetails) {
        self.init(
            id: "\(bl.orderId)",
            remarks: bl.remarks,
            
            totalWeight: bl.totalWeight!.floatValue,
            driveThruSent: bl.driveThruSent!,
            trackingNo: bl.shipping!.trackingNo,
            
            shippingMethodId: bl.shipping!.methodId,
            shippingMethodName: bl.shipping!.method,
            shippingAddress: bl.shipping!.address.full.htmlUnescape(),
            shippingAddressCountryCode: bl.shipping!.address.countryCode,
            shippingAddressName: bl.shipping!.address.name.full,
            
            shippingCost: bl.cost.shipping!.floatValue,
            dispShippingCost: bl.dispCost.shipping!.floatValue
        )
    }
}
