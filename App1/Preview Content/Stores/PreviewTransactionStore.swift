
import SwiftUI



struct PreviewTransactionStore: TransactionStoreProtocol {


    var allTransactions: [Transaction] {
        
        return []
    }
    
    func register(_ transaction: Transaction) {
        
    }
    
    func incomeTransactions(for order: Order) -> [Transaction] {
        
        return []
    }
    
    func dateOrderValidatedWithoutIncomeTransaction(_ order: Order) -> Date? {
        
        return nil
    }
    
    func validateOrderWithoutIncomeTransaction(_ order: Order) {
        
    }
    
    func shippingTransactions(for order: Order) -> [Transaction] {
        
        return []
    }
    
    func dateOrderValidatedWithoutShippingTransaction(_ order: Order) -> Date? {
        
        return nil
    }
    
    func validateOrderWithoutShippingTransaction(_ order: Order) {
        
    }
    
    func refundTransactions(for order: Order) -> [Transaction] {
        
        return []
    }
}
