
import Foundation
import SwiftUI



@Observable
@MainActor
public class TransactionStore {
    
    
    private let transactionCoreController: TransactionCoreController
    
    
    init(_ transactionStore: TransactionCoreController) {
        
        self.transactionCoreController = transactionStore
    }
    
    
    // MARK: - General
    
    
    public var allTransactions: [Core.Transaction] {
        
        transactionCoreController.allTransactions
    }
    
    
    public func register(_ transaction: Core.Transaction) {
        
        transactionCoreController.register(transaction)
    }
    
    
    // MARK: - Income
    
    
    public func incomeTransactions(for order: Order) -> [Core.Transaction] {
        
        transactionCoreController.incomeTransactions(for: order)
    }
    
    
    public func dateOrderValidatedWithoutIncomeTransaction(_ order: Order) -> Date? {
        
        transactionCoreController.dateOrderValidatedWithoutIncomeTransaction(order)
    }
    
    
    public func validateOrderWithoutIncomeTransaction(_ order: Order) {
        
        transactionCoreController.validateOrderWithoutIncomeTransaction(order)
    }
    
    
    // MARK: - Shipping
    
    
    public func shippingTransactions(for order: Order) -> [Core.Transaction] {
        
        transactionCoreController.shippingTransactions(for: order)
    }
    
    
    public func dateOrderValidatedWithoutShippingTransaction(_ order: Order) -> Date? {
        
        transactionCoreController.dateOrderValidatedWithoutShippingTransaction(order)
    }
    
    
    public func validateOrderWithoutShippingTransaction(_ order: Order) {
        
        transactionCoreController.validateOrderWithoutShippingTransaction(order)
    }
    
    
    // MARK: - Refunds
    
    
    public func refundTransactions(for order: Order) -> [Core.Transaction] {
        
        transactionCoreController.refundTransactions(for: order)
    }
}
