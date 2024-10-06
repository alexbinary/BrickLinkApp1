


enum OrderStatus: String, Codable {
    
    case paid = "PAID"
    case packed = "PACKED"
    case shipped = "SHIPPED"
    case received = "RECEIVED"
    case completed = "COMPLETED"
    case purged = "PURGED"
    case cancelled = "CANCELLED"
}



extension OrderStatus {
    
    
    func isOneOf(_ arr: [OrderStatus]) -> Bool {
        
        arr.contains(self)
    }
    
    
    func isNotOneOf(_ arr: [OrderStatus]) -> Bool {
        
        !self.isOneOf(arr)
    }
}
