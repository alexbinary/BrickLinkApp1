
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
    
    
    func incomeTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderIncome && $0.orderRefIn == orderId }
    }
    
    
    func shippingTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderShipping && $0.orderRefIn == orderId }
    }
    
    
    func refundTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderRefund && $0.orderRefIn == orderId }
    }
    
    
    var dateValidatedWithoutIncomeTransactionByOrderId: [OrderSummary.ID: Date] {
        
        dataStore.dateValidatedWithoutIncomeTransactionByOrderId
    }
    
    
    func validateOrderWithoutIncomeTransaction(orderId: OrderDetails.ID) {
        
        try! dataStore.setDateValidatedWithoutIncomeTransaction(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[orderId]
    }
    
    
    func orderIsValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[orderId] != nil
    }
    
    
    var dateValidatedWithoutShippingTransactionByOrderId: [OrderSummary.ID: Date] {
        
        dataStore.dateValidatedWithoutShippingTransactionByOrderId
    }
    
    
    func validateOrderWithoutShippingTransaction(orderId: OrderDetails.ID) {
        
        try! dataStore.setDateValidatedWithoutShippingTransaction(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutShippingTransactionByOrderId[orderId]
    }
    
    
    func orderIsValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutShippingTransactionByOrderId[orderId] != nil
    }
}
