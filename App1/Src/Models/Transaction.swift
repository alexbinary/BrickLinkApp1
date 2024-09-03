
import Foundation



struct Transaction: Identifiable, Codable {
    
    var id: UUID = UUID()
    let date: Date
    let createdAt: Date
    let type: TransactionType
    let amount: Float
    let paymentMethod: String
    let comment: String?
    let orderRefIn: OrderId
}


enum TransactionType: String, Codable {
    
    case orderIncome
    case orderShipping
}


enum PaymentMethod: String, Codable {
    
    case paypal
}
