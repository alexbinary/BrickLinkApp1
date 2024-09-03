
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


enum TransactionType: String, Codable, CaseIterable {
    
    case orderIncome
    case orderShipping
    
    static var incomeTypes: [TransactionType] { [.orderIncome] }
    static var expenseTypes: [TransactionType] { [.orderShipping] }
    
    var isIncome: Bool { Self.incomeTypes.contains(self) }
    var isExpense: Bool { Self.expenseTypes.contains(self) }
}


enum PaymentMethod: String, Codable, CaseIterable {
    
    case paypal
    case cb_iban
}
