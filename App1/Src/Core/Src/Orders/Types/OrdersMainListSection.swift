
import Foundation



public struct OrdersMainListSection {
    
    public let header: String
    public let orders: [OrderSummary]
}



extension Array where Element == OrdersMainListSection {
    
    public var allOrders: [OrderSummary] {
        
        return flatMap(\.orders)
    }
}
