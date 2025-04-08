
import Foundation
import SwiftUI



@Observable
@MainActor
public class TransactionStore {
    
    
    private let transactionController: TransactionController
    
    
    init(_ transactionStore: TransactionController) {
        
        self.transactionController = transactionStore
    }
    
    
    // MARK: - General
    
    
    public var allTransactions: [Core.Transaction] {
        
        transactionController.allTransactions
    }
    
    
    public func register(_ transaction: Core.Transaction) {
        
        transactionController.register(transaction)
    }
    
    
    // MARK: - Income
    
    
    public func incomeTransactions(for order: Order) -> [Core.Transaction] {
        
        transactionController.incomeTransactions(for: order)
    }
    
    
    public func dateOrderValidatedWithoutIncomeTransaction(_ order: Order) -> Date? {
        
        transactionController.dateOrderValidatedWithoutIncomeTransaction(order)
    }
    
    
    public func validateOrderWithoutIncomeTransaction(_ order: Order) {
        
        transactionController.validateOrderWithoutIncomeTransaction(order)
    }
    
    
    // MARK: - Shipping
    
    
    public func shippingTransactions(for order: Order) -> [Core.Transaction] {
        
        transactionController.shippingTransactions(for: order)
    }
    
    
    public func dateOrderValidatedWithoutShippingTransaction(_ order: Order) -> Date? {
        
        transactionController.dateOrderValidatedWithoutShippingTransaction(order)
    }
    
    
    public func validateOrderWithoutShippingTransaction(_ order: Order) {
        
        transactionController.validateOrderWithoutShippingTransaction(order)
    }
    
    
    // MARK: - Refunds
    
    
    public func refundTransactions(for order: Order) -> [Core.Transaction] {
        
        transactionController.refundTransactions(for: order)
    }
}
