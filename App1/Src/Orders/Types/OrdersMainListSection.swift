
import Foundation



struct OrdersMainListSection {
    
    let header: String
    let orders: [OrderSummary]
}



extension Array where Element == OrdersMainListSection {
    
    var allOrders: [OrderSummary] {
        
        return flatMap(\.orders)
    }
}
