


enum OrderStatus: String, Codable {
    
    case paid = "PAID"
    case packed = "PACKED"
    case shipped = "SHIPPED"
    case received = "RECEIVED"
    case completed = "COMPLETED"
    case purged = "PURGED"
    case cancelled = "CANCELLED"
}
