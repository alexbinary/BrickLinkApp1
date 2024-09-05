
import Foundation
import SwiftUI



struct Transaction: Identifiable, Codable, Hashable {
    
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
    
    static func colorFor(_ type: Self) -> Color {
        switch type {
            case .orderIncome: .green
            case .orderShipping: .red
        }
    }
}


enum PaymentMethod: String, Codable, CaseIterable {
    
    case paypal
    case cb_iban
    
    static func colorFor(_ method: Self) -> Color {
        switch method {
            case .paypal: .blue
            case .cb_iban: .gray
        }
    }
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



extension Array where Element == Transaction {
    
    
    func closest(for date: Date) -> Transaction? {
        
        let all = self.sorted { $0.date < $1.date }
        
        let lastBefore = all.last(where: { $0.date < date })
        let firstAfter = all.first(where: { $0.date > date })
        
        if lastBefore == nil || firstAfter == nil {
            return lastBefore ?? firstAfter
        }
        
        let distanceBefore = lastBefore!.date.distance(to: date)
        let distanceAfter = date.distance(to: firstAfter!.date)
        
        if distanceBefore < distanceAfter {
            return lastBefore
        } else {
            return firstAfter
        }
    }
}
