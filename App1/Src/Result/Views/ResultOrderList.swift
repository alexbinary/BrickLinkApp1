
import SwiftUI



struct ResultOrderList: View {
    
    
    @Environment(\.shippingStore)
    var shippingStore: ShippingStoreProtocol!
    
    @Environment(\.refundStore)
    var refundStore: RefundStoreProtocol!
    
    @Environment(ResultStore.self)
    var resultStore
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    
    let orders: [Order]
    let title: String
    let selection: Binding<Order.ID?>
    
    init(_ orders: [Order], title: String, selection: Binding<Order.ID?>) {
        self.orders = orders
        self.title = title
        self.selection = selection
    }
    

    var body: some View {

        VStack(alignment: .leading) {
            
            Text(title).font(.title3)
            
            Table(orders, selection: selection) {
                
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
                    
                    if let orderDetails = orderStore.details(for: order) {
                        
                        Text(
                            abs(orderDetails.shippingCost),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        ).amountColor(.good)
                    }
                }
                
                TableColumn("Shipping cost") { order in
                    Text(
                        abs(shippingStore.confirmedShippingCost(for: order) ?? 0),
                        format: .currency(code: "EUR").presentation(.isoCode)
                    ).amountColor(.bad)
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
            }
        }
    }
}



#Preview {
    
    let env = createEnv()
    
    ResultOrderList([], title: "Title", selection: .constant(nil))
        .inject(env)
}
