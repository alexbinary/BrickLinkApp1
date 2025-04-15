
import Foundation



@MainActor
class TransactionController {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    var allTransactions: [Transaction] {
        
        dataStore.transactions
    }
    
    
    func register(_ transaction: Transaction) {
        
        try! dataStore.addTransaction(transaction)
        try! dataStore.save()
    }
    
    
    func incomeTransactions(for order: Order) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderIncome && $0.orderRefIn == order.id }
    }
    
    
    func shippingTransactions(for order: Order) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderShipping && $0.orderRefIn == order.id }
    }
    
    
    func refundTransactions(for order: Order) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderRefund && $0.orderRefIn == order.id }
    }
    
    
    var dateValidatedWithoutIncomeTransactionByOrderId: [Order.ID: Date] {
        
        dataStore.dateValidatedWithoutIncomeTransactionByOrderId
    }
    
    
    func validateOrderWithoutIncomeTransaction(_ order: Order) {
        
        try! dataStore.setDateValidatedWithoutIncomeTransaction(Date(), forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutIncomeTransaction(_ order: Order) -> Date? {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[order.id]
    }
    
    
    func orderIsValidatedWithoutIncomeTransaction(_ order: Order) -> Bool {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[order.id] != nil
    }
    
    
    var dateValidatedWithoutShippingTransactionByOrderId: [Order.ID: Date] {
        
        dataStore.dateValidatedWithoutShippingTransactionByOrderId
    }
    
    
    func validateOrderWithoutShippingTransaction(_ order: Order) {
        
        try! dataStore.setDateValidatedWithoutShippingTransaction(Date(), forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutShippingTransaction(_ order: Order) -> Date? {
        
        return dateValidatedWithoutShippingTransactionByOrderId[order.id]
    }
    
    
    func orderIsValidatedWithoutShippingTransaction(_ order: Order) -> Bool {
        
        return dateValidatedWithoutShippingTransactionByOrderId[order.id] != nil
    }
}
