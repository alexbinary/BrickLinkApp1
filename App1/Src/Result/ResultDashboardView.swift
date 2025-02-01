
import SwiftUI
import Charts



struct ResultDashboardView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedMostProfitableOrder: OrderDetails.ID? = nil
    @State var selectedLeastProfitableOrder: OrderDetails.ID? = nil
    
    
    var body: some View {
        
        VSplitView {
            
            let periodNLastDays = 30
            
            let orders = appController.orderDetails
                .filter { $0.date.days(to: .now) < periodNLastDays }
                .filter { appController.profitMargin(for: $0) != nil }
            
            let totalItems = orders.reduce(0) { $0 + $1.subTotal }
            let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
            
            let totalItemCost: Float = 0
            let totalShippingCost = orders.reduce(0) { $0 + (appController.shippingCost(forOrderWithId: $1.id) ?? 0) }
            
            let totalFees = orders.reduce(0) { $0 + (appController.fees(for: $1) ?? 0) }
            let totalRefund = orders.flatMap { appController.refunds(for: $0) }.reduce(0) { $0 + $1.amount }
            
            let totalResult = totalItems + totalShipping - totalItemCost - totalShippingCost - totalFees - totalRefund
            
            let profitMargin = appController.profitMargin(
                
                totalItems: totalItems,
                totalShipping: totalShipping,
                
                itemsCost: totalItemCost,
                shippingCost: totalShippingCost,
                
                fees: totalFees,
                refund: totalRefund
                
            ) ?? 0
            
            VStack(spacing: 24) {
                
                Color.clear.frame(height: 1).padding()
                
                Spacer()
                
                VStack {
                    Text(Date.now, style: .date).font(.title3)
                    Text("Last \(periodNLastDays) days").font(.title)
                }
                
                HStack(spacing: 48) {
                    
                    ResultGridView(
                        totalItems: totalItems,
                        totalShipping: totalShipping,
                        totalItemCost: totalItemCost,
                        totalShippingCost: totalShippingCost,
                        totalFees: totalFees,
                        totalRefund: totalRefund,
                        totalResult: totalResult
                    )
                    
                    let innerCircleSize: CGFloat = 100
                    let outerCircleSize: CGFloat = 140
                    
                    ResultCircleView(
                        income: totalItems + totalShipping,
                        expense: totalItemCost + totalShippingCost + totalFees + totalRefund,
                        profitMargin: profitMargin,
                        innerCircleSize: innerCircleSize,
                        outerCircleSize: outerCircleSize
                    )
                    .frame(width: outerCircleSize, height: outerCircleSize)
                }
                
                Text("Counting only orders with complete data").font(.caption)
                
                Color.clear.frame(height: 1).padding()
                
                Spacer()
            }
            
            VStack {
                
                Color.clear.frame(height: 1).padding()
                
                HStack {
                    
                    let orders = orders
                        .filter {
                            appController.profitMargin(for: $0) != nil
                        }
                        .sorted {
                            (appController.profitMargin(for: $0) ?? 0)
                            >
                            (appController.profitMargin(for: $1) ?? 0)
                        }
                    
                    VStack(alignment: .leading) {
                        
                        Text("Most profitable orders").font(.title3)
                        
                        Table(of: OrderDetails.self, selection: $selectedMostProfitableOrder) {
                            
                            TableColumn("ID", value: \.id)
                            
                            TableColumn("Date") { order in
                                Text(order.date, format: .dateTime)
                            }
                            
                            TableColumn("Buyer", value: \.buyer)
                            
                            TableColumn("Profit") { order in
                                
                                if let profitMargin = appController.profitMargin(for: order) {
                                    
                                    Text(
                                        abs(profitMargin),
                                        format: .percent.precision(.fractionLength(0))
                                    ).amountColor(.goodIfPositive(profitMargin, zero: .neutral))
                                }
                            }
                            
                            TableColumn("Items") { order in
                                Text(
                                    abs(order.subTotal),
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).amountColor(.good)
                            }
                            
                            TableColumn("Items cost") { order in
                                Text(
                                    0,
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).amountColor(.bad)
                            }
                            
                            TableColumn("Shipping") { order in
                                Text(
                                    abs(order.shippingCost),
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).amountColor(.good)
                            }
                            
                            TableColumn("Shipping cost") { order in
                                Text(
                                    abs(appController.shippingCost(forOrderWithId: order.id) ?? 0),
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).amountColor(.bad)
                            }
                            
                            TableColumn("Fees") { order in
                                
                                if let fees = appController.fees(for: order) {
                                    
                                    Text(
                                        abs(fees),
                                        format: .currency(code: "EUR").presentation(.isoCode)
                                    ).amountColor(.bad)
                                }
                            }
                            
                            TableColumn("Refund") { order in
                                
                                let totalRefund = appController.refunds(for: order).reduce(0, { $0 + $1.amount })
                                if totalRefund > 0 {
                                    
                                    Text(
                                        abs(totalRefund),
                                        format: .currency(code: "EUR").presentation(.isoCode)
                                    ).amountColor(.bad)
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
                            
                            TableColumn("Profit") { order in
                                
                                if let profitMargin = appController.profitMargin(for: order) {
                                    
                                    Text(
                                        abs(profitMargin),
                                        format: .percent.precision(.fractionLength(0))
                                    ).amountColor(.goodIfPositive(profitMargin, zero: .neutral))
                                }
                            }
                            
                            TableColumn("Items") { order in
                                Text(
                                    abs(order.subTotal),
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).amountColor(.good)
                            }
                            
                            TableColumn("Items cost") { order in
                                Text(
                                    0,
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).amountColor(.bad)
                            }
                            
                            TableColumn("Shipping") { order in
                                Text(
                                    abs(order.shippingCost),
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).amountColor(.good)
                            }
                            
                            TableColumn("Shipping cost") { order in
                                Text(
                                    abs(appController.shippingCost(forOrderWithId: order.id) ?? 0),
                                    format: .currency(code: "EUR").presentation(.isoCode)
                                ).amountColor(.bad)
                            }
                            
                            TableColumn("Fees") { order in
                                
                                if let fees = appController.fees(for: order) {
                                    
                                    Text(
                                        abs(fees),
                                        format: .currency(code: "EUR").presentation(.isoCode)
                                    ).amountColor(.bad)
                                }
                            }
                            
                            TableColumn("Refund") { order in
                                
                                let totalRefund = appController.refunds(for: order).reduce(0, { $0 + $1.amount })
                                if totalRefund > 0 {
                                    
                                    Text(
                                        abs(totalRefund),
                                        format: .currency(code: "EUR").presentation(.isoCode)
                                    ).amountColor(.bad)
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
        }
        .padding()
    }
}
