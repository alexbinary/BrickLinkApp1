
import Foundation



@Observable
class ResultStore {
    
    
    private let orderDataAccess: OrderDataAccess
    private let shippingDataAccess: ShippingDataAccess
    private let refundDataAccess: RefundDataAccess
    private let transactionDataAccess: TransactionDataAccess
    
    
    init(_ orderDataAccess: OrderDataAccess, _ shippingDataAccess: ShippingDataAccess, _ refundDataAccess: RefundDataAccess, _ transactionDataAccess: TransactionDataAccess) {
        self.orderDataAccess = orderDataAccess
        self.shippingDataAccess = shippingDataAccess
        self.refundDataAccess = refundDataAccess
        self.transactionDataAccess = transactionDataAccess
    }
    
    
    public var orderDetails: [OrderDetails] {
        
        orderDataAccess.orderDetails
    }
    
    
    public func shippingCost(forOrderWithId orderId: OrderSummary.ID) -> Float? {
        
        shippingDataAccess.confirmedShippingCost(forOrderWithId: orderId)
    }
    
    
    public func refunds(for order: OrderDetails) -> [OrderRefund] {
        
        refundDataAccess.refunds(for: order)
    }
    
    
    public func incomeTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionDataAccess.incomeTransactions(forOrderWithId: orderId)
    }
    
    
    public func refundTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionDataAccess.refundTransactions(forOrderWithId: orderId)
    }
    
    
    public func profitMargin(for order: OrderDetails) -> Float? {
        
        return profitMargin(
            
            totalItems: order.subTotal,
            totalShipping: order.shippingCost,
        
            itemsCost: 0,
            shippingCost: shippingCost(forOrderWithId: order.id),
            
            fees: fees(for: order),
            refund: refunds(for: order).reduce(0, { $0 + $1.amount })
        )
    }
    
    
    public func profitMargin(
    
        totalItems: Float?,
        totalShipping: Float?,
    
        itemsCost: Float?,
        shippingCost: Float?,
        
        fees: Float?,
        refund: Float?
        
    ) -> Float? {
        
        if
            let totalItems = totalItems,
            let totalShipping = totalShipping,
            
            let itemsCost = itemsCost,
            let shippingCost = shippingCost,
            
            let fees = fees
        {
            let totalIncome = totalItems + totalShipping
            let totalExpense = itemsCost + shippingCost + fees + (refund ?? 0)
            
            return (totalIncome - totalExpense) / totalIncome
        }
        
        return nil
    }
    
    
    public func fees(for order: OrderDetails) -> Float? {
        
        let incomeTransactionsFees = incomeTransactions(forOrderWithId: order.id).compactMap { $0.fees }.reduce(0, +)
        let refundTransactionsFees = refundTransactions(forOrderWithId: order.id).compactMap { $0.fees }.reduce(0, +)
        
        return incomeTransactionsFees - refundTransactionsFees
    }
    
    
    var resultDashboardModel: ResultDashboardModel {
        
        let periodNLastDays = 30
        
        let orders = orderDetails
            .filter { $0.date.days(to: .now) < periodNLastDays }
            .filter { self.profitMargin(for: $0) != nil }
            .sorted { (self.profitMargin(for: $0) ?? 0) > (self.profitMargin(for: $1) ?? 0) }
        
        let totalItems = orders.reduce(0) { $0 + $1.subTotal }
        let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
        
        let totalItemCost: Float = 0
        let totalShippingCost = orders.reduce(0) { $0 + (shippingCost(forOrderWithId: $1.id) ?? 0) }
        
        let totalFees = orders.reduce(0) { $0 + (fees(for: $1) ?? 0) }
        let totalRefund = orders.flatMap { refunds(for: $0) }.reduce(0) { $0 + $1.amount }
        
        let totalResult = totalItems + totalShipping - totalItemCost - totalShippingCost - totalFees - totalRefund
        
        let profitMargin = profitMargin(
            
            totalItems: totalItems,
            totalShipping: totalShipping,
            
            itemsCost: totalItemCost,
            shippingCost: totalShippingCost,
            
            fees: totalFees,
            refund: totalRefund
            
        ) ?? 0
        
        return ResultDashboardModel(
            periodNLastDays: periodNLastDays,
            orders: orders,
            totalItems: totalItems,
            totalShipping: totalShipping,
            totalItemCost: totalItemCost,
            totalShippingCost: totalShippingCost,
            totalFees: totalFees,
            totalRefund: totalRefund,
            totalResult: totalResult,
            profitMargin: profitMargin
        )
    }
}
