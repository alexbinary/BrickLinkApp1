
import Foundation



@Observable
@MainActor
public class ResultStore {
    
    
    private let orderCoreController: OrderCoreController
    private let shippingCoreController: ShippingCoreController
    private let refundCoreController: RefundCoreController
    private let transactionCoreController: TransactionCoreController
    
    
    init(
        _ orderCoreController: OrderCoreController,
        _ shippingCoreController: ShippingCoreController,
        _ refundCoreController: RefundCoreController,
        _ transactionCoreController: TransactionCoreController
    ) {
        self.orderCoreController = orderCoreController
        self.shippingCoreController = shippingCoreController
        self.refundCoreController = refundCoreController
        self.transactionCoreController = transactionCoreController
    }
    
    
    public var orderSummaries: [Order] {
        
        orderCoreController.orderSummaries
    }
    
    
    public var orderDetails: [OrderDetails] {
        
        orderCoreController.orderDetails
    }
    
    
    public func shippingCost(forOrderWithId orderId: Order.ID) -> Float? {
        
        shippingCoreController.confirmedShippingCost(forOrderWithId: orderId)
    }
    
    
    public func refunds(for order: Order) -> [OrderRefund] {
        
        refundCoreController.refunds(for: order)
    }
    
    
    public func incomeTransactions(forOrderWithId orderId: Order.ID) -> [Transaction] {
        
        transactionCoreController.incomeTransactions(forOrderWithId: orderId)
    }
    
    
    public func refundTransactions(forOrderWithId orderId: Order.ID) -> [Transaction] {
        
        transactionCoreController.refundTransactions(forOrderWithId: orderId)
    }
    
    
    // -
    
    
    public func fees(for order: Order) -> Float? {
        
        let incomeTransactionsFees = incomeTransactions(forOrderWithId: order.id).compactMap { $0.fees }.reduce(0, +)
        let refundTransactionsFees = refundTransactions(forOrderWithId: order.id).compactMap { $0.fees }.reduce(0, +)
        
        return incomeTransactionsFees - refundTransactionsFees
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
    
    
    public func profitMargin(for order: Order) -> Float? {
        
        let orderDetails = orderCoreController.orderDetails(forOrderWithId: order.id)!
        
        return profitMargin(
            
            totalItems: order.subTotal,
            totalShipping: orderDetails.shippingCost,
        
            itemsCost: 0,
            shippingCost: shippingCost(forOrderWithId: order.id),
            
            fees: fees(for: order),
            refund: refunds(for: order).reduce(0, { $0 + $1.amount })
        )
    }
    
    
    public var resultDashboardModel: ResultDashboardModel {
        
        let periodNLastDays = 30
        
        let orders = orderSummaries
            .filter { $0.date.days(to: .now) < periodNLastDays }
            .filter { self.profitMargin(for: $0) != nil }
            .sorted { (self.profitMargin(for: $0) ?? 0) > (self.profitMargin(for: $1) ?? 0) }
        
        let totalItems = orders.reduce(0) { $0 + $1.subTotal }
        let totalShipping = orders.map { orderCoreController.orderDetails(forOrderWithId: $0.id)! }.reduce(0) { $0 + $1.shippingCost }
        
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
