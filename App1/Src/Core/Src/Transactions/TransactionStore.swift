
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
    
    
    public func incomeTransactions(forOrderWithId orderId: Order.ID) -> [Core.Transaction] {
        
        transactionCoreController.incomeTransactions(forOrderWithId: orderId)
    }
    
    
    public func dateOrderValidatedWithoutIncomeTransaction(orderId: Order.ID) -> Date? {
        
        transactionCoreController.dateOrderValidatedWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    public func validateOrderWithoutIncomeTransaction(orderId: Order.ID) {
        
        transactionCoreController.validateOrderWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    // MARK: - Shipping
    
    
    public func shippingTransactions(forOrderWithId orderId: Order.ID) -> [Core.Transaction] {
        
        transactionCoreController.shippingTransactions(forOrderWithId: orderId)
    }
    
    
    public func dateOrderValidatedWithoutShippingTransaction(orderId: Order.ID) -> Date? {
        
        transactionCoreController.dateOrderValidatedWithoutShippingTransaction(orderId: orderId)
    }
    
    
    public func validateOrderWithoutShippingTransaction(orderId: Order.ID) {
        
        transactionCoreController.validateOrderWithoutShippingTransaction(orderId: orderId)
    }
    
    
    // MARK: - Refunds
    
    
    public func refundTransactions(forOrderWithId orderId: Order.ID) -> [Core.Transaction] {
        
        transactionCoreController.refundTransactions(forOrderWithId: orderId)
    }
}
