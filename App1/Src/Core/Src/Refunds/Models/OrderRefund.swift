
import Foundation



public struct OrderRefund: Identifiable, Codable, Datable {
    
    public var id: UUID = UUID()
    public var date: Date
    public var amount: Float
    public var comment: String
    public let orderId: OrderSummary.ID
    
    public init(id: UUID = UUID(), date: Date, amount: Float, comment: String, orderId: OrderSummary.ID) {
        self.id = id
        self.date = date
        self.amount = amount
        self.comment = comment
        self.orderId = orderId
    }
}
