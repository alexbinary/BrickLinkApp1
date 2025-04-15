
import Foundation



struct OrderRefund: Identifiable, Codable, Datable {
    
    var id: UUID = UUID()
    var date: Date
    var amount: Float
    var comment: String
    let orderId: Order.ID
    
    init(id: UUID = UUID(), date: Date, amount: Float, comment: String, orderId: Order.ID) {
        self.id = id
        self.date = date
        self.amount = amount
        self.comment = comment
        self.orderId = orderId
    }
}
