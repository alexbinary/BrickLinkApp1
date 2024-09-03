
import Foundation



struct Transaction: Identifiable, Codable {
    
    var id: UUID = UUID()
    let date: Date
    let createdAt: Date
    let type: String
    let amount: Float
    let paymentMethod: String
    let comment: String?
    let orderRefIn: OrderId
}
