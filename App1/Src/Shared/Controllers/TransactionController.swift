
import Foundation
import SwiftUI



@Observable
class TransactionController {
    
    
    private let transactionStore: TransactionStore
    
    
    init(_ transactionStore: TransactionStore) {
        self.transactionStore = transactionStore
    }
    
    
    // MARK: - General
    
    
    public var allTransactions: [Transaction] {
        
        transactionStore.allTransactions
    }
    
    
    public func register(_ transaction: Transaction) {
        
        transactionStore.register(transaction)
    }
    
    
    // MARK: - Income
    
    
    public func incomeTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionStore.incomeTransactions(forOrderWithId: orderId)
    }
    
    
    public func dateOrderValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Date? {
        
        transactionStore.dateOrderValidatedWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    public func validateOrderWithoutIncomeTransaction(orderId: OrderDetails.ID) {
        
        transactionStore.validateOrderWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    // MARK: - Shipping
    
    
    public func shippingTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionStore.shippingTransactions(forOrderWithId: orderId)
    }
    
    
    public func dateOrderValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Date? {
        
        transactionStore.dateOrderValidatedWithoutShippingTransaction(orderId: orderId)
    }
    
    
    public func validateOrderWithoutShippingTransaction(orderId: OrderDetails.ID) {
        
        transactionStore.validateOrderWithoutShippingTransaction(orderId: orderId)
    }
    
    
    // MARK: - Refunds
    
    
    public func refundTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionStore.refundTransactions(forOrderWithId: orderId)
    }
}
