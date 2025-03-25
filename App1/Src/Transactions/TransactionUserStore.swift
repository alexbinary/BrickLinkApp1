
import Foundation
import SwiftUI
import Core



@Observable
class TransactionUserStore {
    
    
    private let transactionCoreController: TransactionCoreController
    
    
    init(_ transactionStore: TransactionCoreController) {
        
        self.transactionCoreController = transactionStore
    }
    
    
    // MARK: - General
    
    
    public var allTransactions: [Transaction] {
        
        transactionCoreController.allTransactions
    }
    
    
    public func register(_ transaction: Transaction) {
        
        transactionCoreController.register(transaction)
    }
    
    
    // MARK: - Income
    
    
    public func incomeTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionCoreController.incomeTransactions(forOrderWithId: orderId)
    }
    
    
    public func dateOrderValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Date? {
        
        transactionCoreController.dateOrderValidatedWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    public func validateOrderWithoutIncomeTransaction(orderId: OrderDetails.ID) {
        
        transactionCoreController.validateOrderWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    // MARK: - Shipping
    
    
    public func shippingTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionCoreController.shippingTransactions(forOrderWithId: orderId)
    }
    
    
    public func dateOrderValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Date? {
        
        transactionCoreController.dateOrderValidatedWithoutShippingTransaction(orderId: orderId)
    }
    
    
    public func validateOrderWithoutShippingTransaction(orderId: OrderDetails.ID) {
        
        transactionCoreController.validateOrderWithoutShippingTransaction(orderId: orderId)
    }
    
    
    // MARK: - Refunds
    
    
    public func refundTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionCoreController.refundTransactions(forOrderWithId: orderId)
    }
}
