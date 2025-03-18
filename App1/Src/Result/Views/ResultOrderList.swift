
import SwiftUI



struct ResultOrderList: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    @Environment(ShippingStore.self)
    var shippingStore
    
    @Environment(RefundStore.self)
    var refundStore
    
    @Environment(ResultController.self)
    var resultController
    
    
    let orders: [OrderDetails]
    let title: String
    let selection: Binding<OrderDetails.ID?>
    
    init(_ orders: [OrderDetails], title: String, selection: Binding<OrderDetails.ID?>) {
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
                    
                    if let profitMargin = resultController.profitMargin(for: order) {
                        
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
                        abs(shippingStore.shippingCost(forOrderWithId: order.id) ?? 0),
                        format: .currency(code: "EUR").presentation(.isoCode)
                    ).amountColor(.bad)
                }
                
                TableColumn("Fees") { order in
                    
                    if let fees = resultController.fees(for: order) {
                        
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
    
    let appController = AppController()
    let shippingStore = appController.shippingStore
    let refundStore = appController.refundStore
    let resultController = appController.resultController
    
    ResultOrderList([], title: "Title", selection: .constant(nil))
        .environmentObject(appController)
        .environment(shippingStore)
        .environment(resultController)
        .environment(refundStore)
}
