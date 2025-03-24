
import SwiftUI



struct ResultContentView: View {
    
    
    @Environment(OrderUserStore.self)
    var orderStore
    
    @Environment(ShippingUserStore.self)
    var shippingStore
    
    @Environment(RefundUserStore.self)
    var refundStore
    
    @Environment(ResultUserStore.self)
    var resultStore
    
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
                
                if let profitMargin = resultStore.profitMargin(for: order) {
                    
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
                
                if let cost = shippingStore.confirmedShippingCost(forOrderWithId: order.id) {
                    
                    Text(
                        abs(cost),
                        format: .currency(code: "EUR").presentation(.isoCode)
                    ).amountColor(.bad)}
            }
            
            TableColumn("Fees") { order in
                
                if let fees = resultStore.fees(for: order) {
                    
                    Text(
                        abs(fees),
                        format: .currency(code: "EUR").presentation(.isoCode)
                    ).amountColor(.bad)
                }
            }
            
            TableColumn("Refund") { order in
                
                let totalRefund = refundStore.refunds(for: order).reduce(0, { $0 + $1.amount })
                if totalRefund > 0 {
                    
                    Text(
                        abs(totalRefund),
                        format: .currency(code: "EUR").presentation(.isoCode)
                    ).amountColor(.bad)
                }
            }
            
        } rows: {
            
            let ordersByMonth = orderStore.orderDetails.grouppedByBusinessMonth.withAllMonthsToCurrent.reversed()
            
            ForEach(ordersByMonth, id: \.month) { (month, elements) in
                Section(month.name) {
                    ForEach(elements) { TableRow($0) }
                }
            }
        }
        .navigationTitle("Result")
    }
}



#Preview {
    
    let env = createEnv()
    let navigationController = NavigationController()
    
    ResultContentView()
        .inject(env)
        .environment(navigationController)
}
