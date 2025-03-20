
import Foundation
import SwiftUI



@Observable
class TransactionStore {
    
    
    private let transactionDataAccess: TransactionDataAccess
    
    
    init(_ transactionDataAccess: TransactionDataAccess) {
        self.transactionDataAccess = transactionDataAccess
    }
    
    
    // MARK: - General
    
    
    public var allTransactions: [Transaction] {
        
        transactionDataAccess.allTransactions
    }
    
    
    public func register(_ transaction: Transaction) {
        
        transactionDataAccess.register(transaction)
    }
    
    
    // MARK: - Income
    
    
    public func incomeTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionDataAccess.incomeTransactions(forOrderWithId: orderId)
    }
    
    
    public func dateOrderValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Date? {
        
        transactionDataAccess.dateOrderValidatedWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    public func validateOrderWithoutIncomeTransaction(orderId: OrderDetails.ID) {
        
        transactionDataAccess.validateOrderWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    // MARK: - Shipping
    
    
    public func shippingTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionDataAccess.shippingTransactions(forOrderWithId: orderId)
    }
    
    
    public func dateOrderValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Date? {
        
        transactionDataAccess.dateOrderValidatedWithoutShippingTransaction(orderId: orderId)
    }
    
    
    public func validateOrderWithoutShippingTransaction(orderId: OrderDetails.ID) {
        
        transactionDataAccess.validateOrderWithoutShippingTransaction(orderId: orderId)
    }
    
    
    // MARK: - Refunds
    
    
    public func refundTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionDataAccess.refundTransactions(forOrderWithId: orderId)
    }
}
