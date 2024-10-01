
import SwiftUI
import Charts



struct ResultDashboardView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            let month: BusinessMonth = .current
            
            let orders = appController.orderDetails.grouppedByMonth[month.name]
            
            let totalItems = orders.reduce(0) { $0 + $1.subTotal }
            let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
            
            let totalItemCost: Float = 0
            let totalShippingCost = orders.reduce(0) { $0 + (appController.shippingCost(forOrderWithId: $1.id) ?? 0) }
            
            let totalFees = orders.reduce(0) { (total: Float, order) in
                
                var fees: Float = 0
                
                if let income = appController.transactions.first(where: { $0.type == .orderIncome && $0.orderRefIn == order.id })?.amount {
                
                    fees = order.grandTotal - income
                }
                
                return total + fees
            }
            
            let totalResult = totalItems + totalShipping - totalItemCost - totalShippingCost - totalFees
            
            let totalIncome = totalItems + totalShipping
            let totalExpense = totalItemCost + totalShippingCost + totalFees
            
            let profitMargin = (totalIncome - totalExpense) / totalIncome
            
            Color.clear.frame(height: 128)
            
            ResultCircleView(
                title: month.name,
                subtitle: "Today",
                totalItems: totalItems,
                totalShipping: totalShipping,
                totalItemCost: totalItemCost,
                totalShippingCost: totalShippingCost,
                totalFees: totalFees,
                totalResult: totalResult,
                profitMargin: profitMargin,
                circleViewVisible: true
            )
            
            Color.clear.frame(height: 128)
            
            HStack {
                
                VStack(alignment: .leading) {
                    
                    Text("Most profitable orders").font(.title3)
                    
                    Table(of: OrderDetails.self) {
                        
                        TableColumn("ID", value: \.id)
                        
                        TableColumn("Date") { order in
                            Text(order.date, format: .dateTime)
                        }
                        
                        TableColumn("Buyer", value: \.buyer)
                        
                        TableColumn("Profit margin") { order in
                            
                            let profitMargin = self.profitMargin(for: order)
                            
                            Text(
                                abs(profitMargin),
                                format: .percent.precision(.fractionLength(0))
                            ).signedAmountColor(profitMargin)
                        }
                        
                        TableColumn("Subtotal (items)") { order in
                            Text(
                                abs(order.subTotal),
                                format: .currency(code: "EUR").presentation(.isoCode)
                            ).signedAmountColor(.income)
                        }
                        
                        TableColumn("Total items cost") { order in
                            Text(
                                0,
                                format: .currency(code: "EUR").presentation(.isoCode)
                            ).signedAmountColor(.expense)
                        }
                        
                        TableColumn("Shipping") { order in
                            Text(
                                abs(order.shippingCost),
                                format: .currency(code: "EUR").presentation(.isoCode)
                            ).signedAmountColor(.income)
                        }
                        
                        TableColumn("Shipping cost") { order in
                            Text(
                                abs(appController.shippingCost(forOrderWithId: order.id) ?? 0),
                                format: .currency(code: "EUR").presentation(.isoCode)
                            ).signedAmountColor(.expense)
                        }
                        
                        TableColumn("Fees") { order in
                            
                            if let transactionAmount = appController.transactions.first(where: { $0.type == .orderIncome && $0.orderRefIn == order.id })?.amount {
                                
                                let fees = order.grandTotal - transactionAmount
                                
                                Text(
                                    abs(fees),
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).signedAmountColor(.expense)
                            }
                        }
                        
                    } rows: {
                        
                        let orders = orders.sorted {
                            
                            self.profitMargin(for: $0) > self.profitMargin(for: $1)
                        }
                        
                        ForEach(orders.limit(5)) { order in
                            TableRow(order)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    
    func profitMargin(for order: OrderDetails) -> Float {
        
        let totalItems = order.subTotal
        let totalShipping = order.shippingCost
        
        let itemsCost: Float = 0
        let shippingCost = appController.shippingCost(forOrderWithId: order.id) ?? 0
        let fees = {
            if let transactionAmount = appController.transactions.first(where: { $0.type == .orderIncome && $0.orderRefIn == order.id })?.amount {
                return order.grandTotal - transactionAmount
            } else {
                return 0
            }
        }()
        
        let totalIncome = totalItems + totalShipping
        let totalExpense = itemsCost + shippingCost + fees
        
        let profitMargin = (totalIncome - totalExpense) / totalIncome
        return profitMargin
    }
}
