
import SwiftUI


struct OrdersContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var selectedOrderId: OrderSummary.ID?
    
    
    var body: some View {
        
        Table(appController.orderSummaries, selection: $selectedOrderId) {
            
            TableColumn("ID", value: \.id)
            TableColumn("Date") { order in
                Text(order.date, format: .dateTime)
            }
            TableColumn("Buyer", value: \.buyer)
            TableColumn("Items (lots)") { order in
                Text(verbatim: "\(order.items) (\(order.lots))")
            }
            TableColumn("Grand total") { order in
                Text(order.grandTotal, format: .currency(code: "EUR").presentation(.isoCode))
            }
            TableColumn("Shipping cost") { order in
                
                var value = appController.shippingCost(forOrderWithId: order.id) ?? 0
                
                let shippingCostBinding = Binding<Float> {
                    return value
                } set: { newValue in
                    value = newValue
                }
                
                TextField("Shipping cost", value: shippingCostBinding,
                          format: .currency(code: "EUR").presentation(.isoCode)
                )
                    .onSubmit {
                        appController.updateShippingCost(forOrderWithId: order.id, cost: value)
                    }
            }
            TableColumn("Status", value: \.status)
            TableColumn("Feedback") { order in
                HStack {
                    Text("Buyer:")
                    if let ratingFromBuyer = appController.orderFeedbacks(forOrderWithId: order.id).first(where: { $0.ratingOfBs == "S" })?.rating {
                        Text(ratingFromBuyer, format: .number)
                    }
                }
                HStack {
                    Text("Me:")
                    if let ratingFromSeller = appController.orderFeedbacks(forOrderWithId: order.id).first(where: { $0.ratingOfBs == "B" })?.rating {
                        Text(ratingFromSeller, format: .number)
                    }
                }
            }
        }
        .navigationTitle("Orders")
    }
}
