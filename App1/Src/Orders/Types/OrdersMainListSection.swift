
import Foundation



struct OrdersMainListSection {
    
    let header: String
    let orders: [Order]
}



extension Array where Element == OrdersMainListSection {
    
    var allOrders: [Order] {
        
        return flatMap(\.orders)
    }
}
