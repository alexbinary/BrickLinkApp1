
import Foundation



public struct Order: Identifiable, Equatable, Codable, Datable {
    
    public let id: String
    public let date: Date
    public let dateStatusChanged: Date
    public let buyer: String
    public let status: OrderStatus
    
    public let items: Int
    public let lots: Int
    
    public let paymentStatus: PaymentStatus
    
    public let subTotal: Float
    public let grandTotal: Float
    public let costCurrencyCode: String

    public let dispSubTotal: Float
    public let dispGrandTotal: Float
    public let dispCostCurrencyCode: String
}



extension Order {
    
    
    public func matches(_ rawSearchText: String) -> Bool {
        
        let searchText = rawSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchText.isEmpty {
            return true
        }
        
        let searchableText = searchableText()
        
        return searchableText.contains(searchText)
    }
    
    
    public func searchableText() -> String {
        
        [
            id
            
        ].map { $0.lowercased() } .joined(separator: " ")
    }
}
