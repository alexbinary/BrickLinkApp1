
import Foundation
import Core



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
    
    let paymentStatus: PaymentStatus
}



extension OrderSummary {
    
    
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
