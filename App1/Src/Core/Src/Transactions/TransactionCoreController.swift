
import Foundation



@MainActor
class TransactionCoreController {
    
    
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
    
    
    func incomeTransactions(forOrderWithId orderId: Order.ID) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderIncome && $0.orderRefIn == orderId }
    }
    
    
    func shippingTransactions(forOrderWithId orderId: Order.ID) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderShipping && $0.orderRefIn == orderId }
    }
    
    
    func refundTransactions(forOrderWithId orderId: Order.ID) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderRefund && $0.orderRefIn == orderId }
    }
    
    
    var dateValidatedWithoutIncomeTransactionByOrderId: [Order.ID: Date] {
        
        dataStore.dateValidatedWithoutIncomeTransactionByOrderId
    }
    
    
    func validateOrderWithoutIncomeTransaction(orderId: Order.ID) {
        
        try! dataStore.setDateValidatedWithoutIncomeTransaction(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutIncomeTransaction(orderId: Order.ID) -> Date? {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[orderId]
    }
    
    
    func orderIsValidatedWithoutIncomeTransaction(orderId: Order.ID) -> Bool {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[orderId] != nil
    }
    
    
    var dateValidatedWithoutShippingTransactionByOrderId: [Order.ID: Date] {
        
        dataStore.dateValidatedWithoutShippingTransactionByOrderId
    }
    
    
    func validateOrderWithoutShippingTransaction(orderId: Order.ID) {
        
        try! dataStore.setDateValidatedWithoutShippingTransaction(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutShippingTransaction(orderId: Order.ID) -> Date? {
        
        return dateValidatedWithoutShippingTransactionByOrderId[orderId]
    }
    
    
    func orderIsValidatedWithoutShippingTransaction(orderId: Order.ID) -> Bool {
        
        return dateValidatedWithoutShippingTransactionByOrderId[orderId] != nil
    }
}
