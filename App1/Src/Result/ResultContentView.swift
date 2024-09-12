
import SwiftUI



struct ResultContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var selectedOrderIds: Set<OrderSummary.ID>
    
    
    var body: some View {
        
        Table(appController.orderSummaries, selection: $selectedOrderIds) {
            
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
        }
        .navigationTitle("Result")
    }
}
