
import Foundation



struct Order: Identifiable, Equatable, Codable, Datable, Sendable {
    
    let id: String
    let date: Date
    let dateStatusChanged: Date
    var unchangedFor30Days: Bool { dateStatusChanged.days(to: Date()) > 30 }
    let buyer: String
    let status: OrderStatus
    
    let items: Int
    let lots: Int
    
    let paymentStatus: PaymentStatus
    
    let subTotal: Float
    let grandTotal: Float
    let costCurrencyCode: String
    
    let dispSubTotal: Float
    let dispGrandTotal: Float
    let dispCostCurrencyCode: String
}



extension Order {
    
    
    init(fromBl bl: BrickLinkOrderSummary) {
        self.init(
            id: "\(bl.orderId)",
            date: bl.dateOrdered,
            dateStatusChanged: bl.dateStatusChanged,
            buyer: bl.buyerName,
            status: OrderStatus(rawValue: bl.status)!,
            
            items: bl.totalCount,
            lots: bl.uniqueCount,
            
            paymentStatus: PaymentStatus(rawValue: bl.payment.status)!,
            
            subTotal: bl.cost.subtotal.floatValue,
            grandTotal: bl.cost.grandTotal.floatValue,
            costCurrencyCode: bl.cost.currencyCode,
            
            dispSubTotal: bl.dispCost.subtotal.floatValue,
            dispGrandTotal: bl.dispCost.grandTotal.floatValue,
            dispCostCurrencyCode: bl.dispCost.currencyCode
        )
    }
}



extension Order {
    
    
    func matches(_ rawSearchText: String) -> Bool {
        
        let searchText = rawSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchText.isEmpty {
            return true
        }
        
        let searchableText = searchableText()
        
        return searchableText.contains(searchText)
    }
    
    
    func searchableText() -> String {
        
        [
            id
            
        ].map { $0.lowercased() } .joined(separator: " ")
    }
}
