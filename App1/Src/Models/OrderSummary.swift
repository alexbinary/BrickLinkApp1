
import Foundation



struct OrderSummary: Identifiable, Equatable, Codable, Datable {
    
    let id: String
    let date: Date
    let buyer: String
    let items: Int
    let lots: Int
    
    let subTotal: Float
    let grandTotal: Float
    let costCurrencyCode: String
    
    let dispSubTotal: Float
    let dispGrandTotal: Float
    let dispCostCurrencyCode: String
    
    let status: OrderStatus
    let dateStatusChanged: Date
}
