
import Foundation



@Observable
@MainActor
public class ResultStore {
    
    
    private let orderController: OrderController
    private let shippingController: ShippingController
    private let refundController: RefundController
    private let transactionController: TransactionController
    
    
    init(
        _ orderController: OrderController,
        _ shippingController: ShippingController,
        _ refundController: RefundController,
        _ transactionController: TransactionController
    ) {
        self.orderController = orderController
        self.shippingController = shippingController
        self.refundController = refundController
        self.transactionController = transactionController
    }
    
    
    public var orders: [Order] {
        
        orderController.orders
    }
    
    
    public func shippingCost(for order: Order) -> Float? {
        
        shippingController.confirmedShippingCost(for: order)
    }
    
    
    public func refunds(for order: Order) -> [OrderRefund] {
        
        refundController.refunds(for: order)
    }
    
    
    public func incomeTransactions(for order: Order) -> [Transaction] {
        
        transactionController.incomeTransactions(for: order)
    }
    
    
    public func refundTransactions(for order: Order) -> [Transaction] {
        
        transactionController.refundTransactions(for: order)
    }
    
    
    // -
    
    
    public func fees(for order: Order) -> Float? {
        
        let incomeTransactionsFees = incomeTransactions(for: order).compactMap { $0.fees }.reduce(0, +)
        let refundTransactionsFees = refundTransactions(for: order).compactMap { $0.fees }.reduce(0, +)
        
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
        
        if let orderDetails = orderController.details(for: order) {
            
            return profitMargin(
                
                totalItems: order.subTotal,
                totalShipping: orderDetails.shippingCost,
                
                itemsCost: 0,
                shippingCost: shippingCost(for: order),
                
                fees: fees(for: order),
                refund: refunds(for: order).reduce(0, { $0 + $1.amount })
            )
        }
        
        return nil
    }
    
    
    public var resultDashboardModel: ResultDashboardModel {
        
        let periodNLastDays = 30
        
        let orders = orders
            .filter { $0.date.days(to: .now) < periodNLastDays }
            .filter { self.profitMargin(for: $0) != nil }
            .sorted { (self.profitMargin(for: $0) ?? 0) > (self.profitMargin(for: $1) ?? 0) }
        
        let totalItems = orders.reduce(0) { $0 + $1.subTotal }
        let totalShipping = orders.compactMap { orderController.details(for: $0) }.reduce(0) { $0 + $1.shippingCost }
        
        let totalItemCost: Float = 0
        let totalShippingCost = orders.reduce(0) { $0 + (shippingCost(for: $1) ?? 0) }
        
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
