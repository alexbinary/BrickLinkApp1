
import Foundation



public struct OrdersMainListSection {
    
    public let header: String
    public let orders: [Order]
}



extension Array where Element == OrdersMainListSection {
    
    public var allOrders: [Order] {
        
        return flatMap(\.orders)
    }
}
