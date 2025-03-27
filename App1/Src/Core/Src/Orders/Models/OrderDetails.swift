
import Foundation



public struct OrderDetails: Identifiable, Equatable, Codable, Datable {
    
    public let id: String
    public let date: Date
    public let dateStatusChanged: Date
    public let buyer: String
    public let status: OrderStatus
    public let remarks: String?
    
    public let items: Int
    public let lots: Int
    public let totalWeight: Float
    public let driveThruSent: Bool
    public let trackingNo: String?
    
    public let paymentStatus: PaymentStatus
    
    public let shippingMethodId: Int
    public let shippingMethodName: String?
    public let shippingAddress: String
    public let shippingAddressCountryCode: String
    public let shippingAddressName: String
    
    public let subTotal: Float
    public let grandTotal: Float
    public let shippingCost: Float
    public let costCurrencyCode: String
    
    public let dispSubTotal: Float
    public let dispGrandTotal: Float
    public let dispShippingCost: Float
    public let dispCostCurrencyCode: String
    
    public var isShippedWithLaPoste: Bool { shippingMethodId.isOneOf(shippingMethodIds_LaPoste) }
}



extension OrderDetails {
    
    
    public func differs(from summary: Order) -> Bool {
        
        return
            self.id != summary.id
         || self.date != summary.date
         || self.buyer != summary.buyer
         || self.items != summary.items
         || self.lots != summary.lots
         || self.subTotal != summary.subTotal
         || self.grandTotal != summary.grandTotal
         || self.costCurrencyCode != summary.costCurrencyCode
         || self.dispSubTotal != summary.dispSubTotal
         || self.dispGrandTotal != summary.dispGrandTotal
         || self.dispCostCurrencyCode != summary.dispCostCurrencyCode
         || self.status != summary.status
    }
}
