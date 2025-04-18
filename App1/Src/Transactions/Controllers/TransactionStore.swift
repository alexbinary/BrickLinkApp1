
import SwiftUI



@MainActor
protocol TransactionStoreProtocol {
    
    var allTransactions: [Transaction] { get }
    func register(_ transaction: Transaction)

    func incomeTransactions(for order: Order) -> [Transaction]
    func dateOrderValidatedWithoutIncomeTransaction(_ order: Order) -> Date?
    func validateOrderWithoutIncomeTransaction(_ order: Order)

    func shippingTransactions(for order: Order) -> [Transaction]
    func dateOrderValidatedWithoutShippingTransaction(_ order: Order) -> Date?
    func validateOrderWithoutShippingTransaction(_ order: Order)

    func refundTransactions(for order: Order) -> [Transaction]
}



@Observable
@MainActor
class TransactionStore: TransactionStoreProtocol {
    
    
    private let transactionController: TransactionController
    
    
    init(_ transactionStore: TransactionController) {
        
        self.transactionController = transactionStore
    }
    
    
    // MARK: - General
    
    
    var allTransactions: [Transaction] {
        
        transactionController.allTransactions
    }
    
    
    func register(_ transaction: Transaction) {
        
        transactionController.register(transaction)
    }
    
    
    // MARK: - Income
    
    
    func incomeTransactions(for order: Order) -> [Transaction] {
        
        transactionController.incomeTransactions(for: order)
    }
    
    
    func dateOrderValidatedWithoutIncomeTransaction(_ order: Order) -> Date? {
        
        transactionController.dateOrderValidatedWithoutIncomeTransaction(order)
    }
    
    
    func validateOrderWithoutIncomeTransaction(_ order: Order) {
        
        transactionController.validateOrderWithoutIncomeTransaction(order)
    }
    
    
    // MARK: - Shipping
    
    
    func shippingTransactions(for order: Order) -> [Transaction] {
        
        transactionController.shippingTransactions(for: order)
    }
    
    
    func dateOrderValidatedWithoutShippingTransaction(_ order: Order) -> Date? {
        
        transactionController.dateOrderValidatedWithoutShippingTransaction(order)
    }
    
    
    func validateOrderWithoutShippingTransaction(_ order: Order) {
        
        transactionController.validateOrderWithoutShippingTransaction(order)
    }
    
    
    // MARK: - Refunds
    
    
    func refundTransactions(for order: Order) -> [Transaction] {
        
        transactionController.refundTransactions(for: order)
    }
}
