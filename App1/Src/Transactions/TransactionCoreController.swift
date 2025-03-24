
import Foundation



class TransactionCoreController {
    
    
    private let fileDataAccess: FileDataAccess
    
    
    init(_ fileDataAccess: FileDataAccess) {
        self.fileDataAccess = fileDataAccess
    }
    
    
    public var allTransactions: [Transaction] {
        
        fileDataAccess.transactions
    }
    
    
    public func register(_ transaction: Transaction) {
        
        try! fileDataAccess.addTransaction(transaction)
        try! fileDataAccess.save()
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
        
        fileDataAccess.dateValidatedWithoutIncomeTransactionByOrderId
    }
    
    
    public func validateOrderWithoutIncomeTransaction(orderId: OrderDetails.ID) {
        
        try! fileDataAccess.setDateValidatedWithoutIncomeTransaction(Date(), forOrderId: orderId)
        try! fileDataAccess.save()
    }
    
    
    public func dateOrderValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[orderId]
    }
    
    
    public func orderIsValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[orderId] != nil
    }
    
    
    public var dateValidatedWithoutShippingTransactionByOrderId: [OrderSummary.ID: Date] {
        
        fileDataAccess.dateValidatedWithoutShippingTransactionByOrderId
    }
    
    
    public func validateOrderWithoutShippingTransaction(orderId: OrderDetails.ID) {
        
        try! fileDataAccess.setDateValidatedWithoutShippingTransaction(Date(), forOrderId: orderId)
        try! fileDataAccess.save()
    }
    
    
    public func dateOrderValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutShippingTransactionByOrderId[orderId]
    }
    
    
    public func orderIsValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutShippingTransactionByOrderId[orderId] != nil
    }
}
