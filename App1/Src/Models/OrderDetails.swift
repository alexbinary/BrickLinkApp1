
import Foundation



struct OrderDetails: Identifiable, Equatable, Codable, Datable {
    
    let id: String
    let date: Date
    let buyer: String
    let items: Int
    let lots: Int
    
    let subTotal: Float
    let grandTotal: Float
    let shippingCost: Float
    let costCurrencyCode: String
    
    let dispSubTotal: Float
    let dispGrandTotal: Float
    let dispShippingCost: Float
    let dispCostCurrencyCode: String
    
    let status: String
    let driveThruSent: Bool
    let trackingNo: String?
    let totalWeight: Float
    
    let shippingMethodId: Int
    let shippingMethodName: String?
    let shippingAddress: String
    let shippingAddressCountryCode: String
    let shippingAddressName: String
}
