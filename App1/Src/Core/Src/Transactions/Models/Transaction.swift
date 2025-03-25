
import Foundation
import SwiftUI



public struct Transaction: Identifiable, Codable, Hashable, Datable {
    
    public var id: UUID = UUID()
    public var date: Date
    public let createdAt: Date
    public let type: TransactionType
    public var amount: Float
    public let fees: Float?
    public var netAmount: Float { amount - (fees ?? 0) }
    public var paymentMethod: PaymentMethod
    public var comment: String
    public let orderRefIn: OrderSummary.ID
    
    public init(id: UUID = UUID(), date: Date, createdAt: Date, type: TransactionType, amount: Float, fees: Float?, paymentMethod: PaymentMethod, comment: String, orderRefIn: OrderSummary.ID) {
        self.id = id
        self.date = date
        self.createdAt = createdAt
        self.type = type
        self.amount = amount
        self.fees = fees
        self.paymentMethod = paymentMethod
        self.comment = comment
        self.orderRefIn = orderRefIn
    }
}


public enum TransactionType: String, Codable, CaseIterable {
    
    case orderIncome
    case orderRefund
    case orderShipping
    
    public static var incomeTypes: [TransactionType] { [.orderIncome] }
    public static var expenseTypes: [TransactionType] { [.orderShipping, .orderRefund] }
    
    public var isIncome: Bool { Self.incomeTypes.contains(self) }
    public var isExpense: Bool { Self.expenseTypes.contains(self) }
    
    public static func graphColorFor(_ type: Self) -> Color {
        switch type {
            case .orderIncome: .green
            case .orderShipping: .red
            case .orderRefund: .yellow
        }
    }
}


public enum PaymentMethod: String, Codable, CaseIterable {
    
    case paypal
    case cb_iban
    
    public static func graphColorFor(_ method: Self) -> Color {
        switch method {
            case .paypal: .blue
            case .cb_iban: .gray
        }
    }
}



extension Array where Element == Transaction {
    
    
    public func closest(for date: Date) -> Transaction? {
        
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
