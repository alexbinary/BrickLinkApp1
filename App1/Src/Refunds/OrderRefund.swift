
import Foundation
import Core



struct OrderRefund: Identifiable, Codable, Datable {
    
    var id: UUID = UUID()
    var date: Date
    var amount: Float
    var comment: String
    let orderId: OrderSummary.ID
}
