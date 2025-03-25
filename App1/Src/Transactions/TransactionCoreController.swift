
import Foundation
import Core



class TransactionCoreController {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    public var allTransactions: [Transaction] {
        
        dataStore.transactions
    }
    
    
    public func register(_ transaction: Transaction) {
        
        try! dataStore.addTransaction(transaction)
        try! dataStore.save()
    }
    
    
    public func incomeTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderIncome && $0.orderRefIn == orderId }
    }
    
    
    public func shippingTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderShipping && $0.orderRefIn == orderId }
    }
    
    
    public func refundTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        return allTransactions.filter { $0.type == .orderRefund && $0.orderRefIn == orderId }
    }
    
    
    public var dateValidatedWithoutIncomeTransactionByOrderId: [OrderSummary.ID: Date] {
        
        dataStore.dateValidatedWithoutIncomeTransactionByOrderId
    }
    
    
    public func validateOrderWithoutIncomeTransaction(orderId: OrderDetails.ID) {
        
        try! dataStore.setDateValidatedWithoutIncomeTransaction(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func dateOrderValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[orderId]
    }
    
    
    public func orderIsValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[orderId] != nil
    }
    
    
    public var dateValidatedWithoutShippingTransactionByOrderId: [OrderSummary.ID: Date] {
        
        dataStore.dateValidatedWithoutShippingTransactionByOrderId
    }
    
    
    public func validateOrderWithoutShippingTransaction(orderId: OrderDetails.ID) {
        
        try! dataStore.setDateValidatedWithoutShippingTransaction(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func dateOrderValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutShippingTransactionByOrderId[orderId]
    }
    
    
    public func orderIsValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutShippingTransactionByOrderId[orderId] != nil
    }
}
