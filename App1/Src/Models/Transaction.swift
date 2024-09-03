
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



extension Array where Element == Transaction {
    
    
    var grouppedByMonth: [(month: String, transactions: [Transaction])] {
        
        let withMonth: [(month: String, transaction: Transaction)] = self.map {
            
            let cal = Calendar.current
            
            let comps = cal.dateComponents([.month, .year], from: $0.date)
            let month = "\(cal.monthSymbols[comps.month!-1]) \(comps.year!)"
            
            return (month: month, transaction: $0)
        }
        
        return withMonth.map { $0.month } .stableUniqueByFirstOccurence .map { month in
            
            return (
                month: month,
                transactions: withMonth.filter { $0.month == month } .map { $0.transaction }
            )
        }
    }
}
