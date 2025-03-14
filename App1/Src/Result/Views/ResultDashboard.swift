
import SwiftUI
import Charts



struct ResultDashboard: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    
    @State var selectedMostProfitableOrder: OrderDetails.ID? = nil
    @State var selectedLeastProfitableOrder: OrderDetails.ID? = nil
    
    
    var body: some View {
        
        VSplitView {
            
            let model = app.resultDashboardModel
            
            let periodNLastDays = model.periodNLastDays
            let orders = model.orders
            
            let totalItems = model.totalItems
            let totalShipping = model.totalShipping
            
            let totalItemCost = model.totalItemCost
            let totalShippingCost = model.totalShippingCost
            
            let totalFees = model.totalFees
            let totalRefund = model.totalRefund
            
            let totalResult = model.totalResult
            let profitMargin = model.profitMargin
            
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
                    orderList(orders.limit(5),
                              title: "Most profitable orders", selection: $selectedMostProfitableOrder)
                    orderList(orders.reversed().limit(5),
                              title: "Least profitable orders", selection: $selectedLeastProfitableOrder)
                }
            }
        }
        .padding()
    }
    
    
    @ViewBuilder
    func orderList(_ orders: [OrderDetails], title: String, selection: Binding<OrderDetails.ID?>) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(title).font(.title3)
            
            Table(orders, selection: selection) {
                
                TableColumn("ID", value: \.id)
                
                TableColumn("Date") { order in
                    Text(order.date, format: .dateTime)
                }
                
                TableColumn("Buyer", value: \.buyer)
                
                TableColumn("Profit") { order in
                    
                    if let profitMargin = app.profitMargin(for: order) {
                        
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
                        abs(app.shippingCost(forOrderWithId: order.id) ?? 0),
                        format: .currency(code: "EUR").presentation(.isoCode)
                    ).amountColor(.bad)
                }
                
                TableColumn("Fees") { order in
                    
                    if let fees = app.fees(for: order) {
                        
                        Text(
                            abs(fees),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        ).amountColor(.bad)
                    }
                }
                
                TableColumn("Refund") { order in
                    
                    let totalRefund = app.refunds(for: order).reduce(0, { $0 + $1.amount })
                    if totalRefund > 0 {
                        
                        Text(
                            abs(totalRefund),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        ).amountColor(.bad)
                    }
                }
            }
        }
    }
}
