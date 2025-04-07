
import Core



enum ReloadItem: Identifiable, Equatable {
    
    var id: String {
        switch self {
        case .inventoryAndColors: "inventory-and-colors"
        case .orders: "orders"
        case .order(let orderId, let includeDetails): "order-\(orderId)\(includeDetails ? "-details" : "")"
        case .items(let orderId): "items-\(orderId)"
        case .feedbacks(let orderId): "feedbacks-\(orderId)"
        }
    }
    
    case inventoryAndColors
    case orders
    case order(orderId: Order.ID, includeDetails: Bool)
    case items(orderId: Order.ID)
    case feedbacks(orderId: Order.ID)
}
