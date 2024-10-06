
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
    
    let status: OrderStatus
    let driveThruSent: Bool
    let trackingNo: String?
    let totalWeight: Float
    
    let shippingMethodId: Int
    let shippingMethodName: String?
    let shippingAddress: String
    let shippingAddressCountryCode: String
    let shippingAddressName: String
}



extension OrderDetails {
    
    
    func differs(from summary: OrderSummary) -> Bool {
        
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
