
import SwiftUI
import Charts



struct ResultDashboardView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedMostProfitableOrder: OrderDetails.ID? = nil
    @State var selectedLeastProfitableOrder: OrderDetails.ID? = nil
    
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            let month: BusinessMonth = .current
            
            let orders = appController.orderDetails.grouppedByMonth[month.name]
            
            let totalItems = orders.reduce(0) { $0 + $1.subTotal }
            let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
            
            let totalItemCost: Float = 0
            let totalShippingCost = orders.reduce(0) { $0 + (appController.shippingCost(forOrderWithId: $1.id) ?? 0) }
            
            let totalFees = orders.reduce(0) { (total: Float, order) in
                
                let fees = appController.fees(for: order) ?? 0
                
                return total + fees
            }
            
            let totalResult = totalItems + totalShipping - totalItemCost - totalShippingCost - totalFees
            
            let totalIncome = totalItems + totalShipping
            let totalExpense = totalItemCost + totalShippingCost + totalFees
            
            let profitMargin = (totalIncome - totalExpense) / totalIncome
            
            Color.clear.frame(height: 128)
            
            VStack(spacing: 24) {
                
                VStack {
                    Text("Today").font(.title3)
                    Text(month.name).font(.title)
                }
                
                HStack(spacing: 48) {
                    
                    ResultGridView(
                        totalItems: totalItems,
                        totalShipping: totalShipping,
                        totalItemCost: totalItemCost,
                        totalShippingCost: totalShippingCost,
                        totalFees: totalFees,
                        totalResult: totalResult
                    )
                    
                    let innerCircleSize: CGFloat = 100
                    let outerCircleSize: CGFloat = 140
                    
                    ResultCircleView(
                        totalItems: totalItems,
                        totalShipping: totalShipping,
                        totalItemCost: totalItemCost,
                        totalShippingCost: totalShippingCost,
                        totalFees: totalFees,
                        profitMargin: profitMargin,
                        innerCircleSize: innerCircleSize,
                        outerCircleSize: outerCircleSize
                    )
                    .frame(width: outerCircleSize, height: outerCircleSize)
                }
            }
            
            Color.clear.frame(height: 128)
            
            HStack {
                
                let orders = orders.sorted {
                    
                    appController.profitMargin(for: $0) > appController.profitMargin(for: $1)
                }
                
                VStack(alignment: .leading) {
                    
                    Text("Most profitable orders").font(.title3)
                    
                    Table(of: OrderDetails.self, selection: $selectedMostProfitableOrder) {
                        
                        TableColumn("ID", value: \.id)
                        
                        TableColumn("Date") { order in
                            Text(order.date, format: .dateTime)
                        }
                        
                        TableColumn("Buyer", value: \.buyer)
                        
                        TableColumn("Profit margin") { order in
                            
                            let profitMargin = appController.profitMargin(for: order)
                            
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
                            
                            if let fees = appController.fees(for: order) {
                                
                                Text(
                                    abs(fees),
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).signedAmountColor(.expense)
                            }
                        }
                        
                    } rows: {
                        
                        ForEach(orders.limit(5)) { order in
                            TableRow(order)
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    
                    Text("Least profitable orders").font(.title3)
                    
                    Table(of: OrderDetails.self, selection: $selectedLeastProfitableOrder) {
                        
                        TableColumn("ID", value: \.id)
                        
                        TableColumn("Date") { order in
                            Text(order.date, format: .dateTime)
                        }
                        
                        TableColumn("Buyer", value: \.buyer)
                        
                        TableColumn("Profit margin") { order in
                            
                            let profitMargin = appController.profitMargin(for: order)
                            
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
                            
                            if let fees = appController.fees(for: order) {
                                
                                Text(
                                    abs(fees),
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).signedAmountColor(.expense)
                            }
                        }
                        
                    } rows: {
                        
                        ForEach(orders.reversed().limit(5)) { order in
                            TableRow(order)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
