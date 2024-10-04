
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
            
            TableColumn("Items") { order in
                Text(order.subTotal, format: .currency(code: "EUR").presentation(.isoCode))
            }
            
            TableColumn("Shipping") { order in
                if let details = appController.orderDetails(forOrderWithId: order.id) {
                    Text(details.shippingCost, format: .currency(code: "EUR").presentation(.isoCode))
                }
            }
            
            TableColumn("Items cost") { order in
                Text(0, format: .currency(code: "EUR").presentation(.isoCode))
            }
            
            TableColumn("Shipping cost") { order in
                if let sc = appController.shippingCost(forOrderWithId: order.id) {
                    Text(sc, format: .currency(code: "EUR").presentation(.isoCode))
                }
            }
            
        } rows: {
            
            let ordersByMonth = appController.orderDetails.grouppedByBusinessMonth
            
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
