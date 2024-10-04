
import SwiftUI



struct ResultContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var selectedOrderIds: Set<OrderSummary.ID>
    
    
    var body: some View {
        
        Table(of: OrderDetails.self, selection: $selectedOrderIds) {
            
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
                    ).signedAmountColor(profitMargin)
                }
            }
            
            TableColumn("Items") { order in
                Text(
                    abs(order.subTotal),
                    format: .currency(code: "EUR").presentation(.isoCode)
                ).signedAmountColor(.income)
            }
            
            TableColumn("Items cost") { order in
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
            
            let ordersByMonth = appController.orderDetails
                .filter { appController.profitMargin(for: $0) != nil }
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
