
import Foundation



struct Transaction: Identifiable, Codable {
    
    var id: UUID = UUID()
    var date: Date
    let createdAt: Date
    let type: TransactionType
    var amount: Float
    var paymentMethod: PaymentMethod
    var comment: String
    let orderRefIn: OrderId
}


enum TransactionType: String, Codable {
    
    case orderIncome
    case orderShipping
}


enum PaymentMethod: String, Codable, CaseIterable {
    
    case paypal
    case cb_iban
}
