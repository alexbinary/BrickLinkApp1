
import SwiftUI



struct ResultContentView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    @Environment(NavigationController.self)
    var nav
    
    
    var body: some View {
        
        @Bindable var nav = nav
        
        Table(of: OrderDetails.self, selection: $nav.resultSelectedOrderIds) {
            
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
                
                if let cost = app.shippingCost(forOrderWithId: order.id) {
                    
                    Text(
                        abs(cost),
                        format: .currency(code: "EUR").presentation(.isoCode)
                    ).amountColor(.bad)}
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
            
        } rows: {
            
            let ordersByMonth = app.orderDetails
                .grouppedByBusinessMonth
            
            let orderMonths = ordersByMonth.map { $0.month } .unique.sorted()
            
            let allMonths: [BusinessMonth] = {
                if let first = orderMonths.first {
                    return BusinessMonth.allMonths(
                        between: first, and: .current
                    )
                } else {
                    return []
                }
            }()
            
            ForEach(allMonths.reversed()) { month in
                
                Section(month.name) {
                    
                    let orders = ordersByMonth[month].sorted { $0.date > $1.date }
                    
                    ForEach(orders) { order in

                        TableRow(order)
                    }
                }
            }
        }
        .navigationTitle("Result")
    }
}
