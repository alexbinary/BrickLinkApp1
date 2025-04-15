
import Foundation



struct OrderDetails: Identifiable, Equatable, Codable {
    
    let id: String
    let remarks: String?
    
    let totalWeight: Float
    let driveThruSent: Bool
    let trackingNo: TrackingNo?
    
    let shippingMethodId: Int
    let shippingMethodName: String?
    let shippingAddress: String
    let shippingAddressCountryCode: String
    let shippingAddressName: String
    
    let shippingCost: Float
    let dispShippingCost: Float
    
    var shipsToFrance: Bool { shippingMethodId.isOneOf(shippingMethodIds_France) }
    var shipsWithLaPoste: Bool { shippingMethodId.isOneOf(shippingMethodIds_LaPoste) }
    var shipsWithMondialRelay: Bool { shippingMethodId.isOneOf(shippingMethodIds_MondialRelay) }
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
