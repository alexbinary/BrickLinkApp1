
import Foundation



public struct OrderDetails: Identifiable, Equatable, Codable, Datable {
    
    public let id: String
    public let date: Date
    public let buyer: String
    public let items: Int
    public let lots: Int
    
    public let subTotal: Float
    public let grandTotal: Float
    public let shippingCost: Float
    public let costCurrencyCode: String
    
    public let dispSubTotal: Float
    public let dispGrandTotal: Float
    public let dispShippingCost: Float
    public let dispCostCurrencyCode: String
    
    public let status: OrderStatus
    public let driveThruSent: Bool
    public let trackingNo: String?
    public let totalWeight: Float
    
    public let shippingMethodId: Int
    public let shippingMethodName: String?
    public let shippingAddress: String
    public let shippingAddressCountryCode: String
    public let shippingAddressName: String
    
    public let remarks: String?
    
    
    public var isShippedWithLaPoste: Bool { shippingMethodId.isOneOf(shippingMethodIds_LaPoste) }
    
    
    public init(id: String, date: Date, buyer: String, items: Int, lots: Int, subTotal: Float, grandTotal: Float, shippingCost: Float, costCurrencyCode: String, dispSubTotal: Float, dispGrandTotal: Float, dispShippingCost: Float, dispCostCurrencyCode: String, status: OrderStatus, driveThruSent: Bool, trackingNo: String?, totalWeight: Float, shippingMethodId: Int, shippingMethodName: String?, shippingAddress: String, shippingAddressCountryCode: String, shippingAddressName: String, remarks: String?) {
        self.id = id
        self.date = date
        self.buyer = buyer
        self.items = items
        self.lots = lots
        self.subTotal = subTotal
        self.grandTotal = grandTotal
        self.shippingCost = shippingCost
        self.costCurrencyCode = costCurrencyCode
        self.dispSubTotal = dispSubTotal
        self.dispGrandTotal = dispGrandTotal
        self.dispShippingCost = dispShippingCost
        self.dispCostCurrencyCode = dispCostCurrencyCode
        self.status = status
        self.driveThruSent = driveThruSent
        self.trackingNo = trackingNo
        self.totalWeight = totalWeight
        self.shippingMethodId = shippingMethodId
        self.shippingMethodName = shippingMethodName
        self.shippingAddress = shippingAddress
        self.shippingAddressCountryCode = shippingAddressCountryCode
        self.shippingAddressName = shippingAddressName
        self.remarks = remarks
    }
}



extension OrderDetails {
    
    
    public func differs(from summary: OrderSummary) -> Bool {
        
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
