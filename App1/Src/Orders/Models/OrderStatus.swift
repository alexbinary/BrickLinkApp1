
import Core



enum OrderStatus: String, Codable, IsOneOfAble {
    
    case paid = "PAID"
    case packed = "PACKED"
    case shipped = "SHIPPED"
    case received = "RECEIVED"
    case completed = "COMPLETED"
    
    case purged = "PURGED"
    case cancelled = "CANCELLED"
}
