
import SwiftUI


struct PickingContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var selectedOrderIds: Set<Order.ID>
    
    
    var body: some View {
        
        Table(appController.orders, selection: $selectedOrderIds) {
            
            TableColumn("ID", value: \.id)
            TableColumn("Date") { order in
                Text(order.date, format: .dateTime)
            }
            TableColumn("Buyer", value: \.buyer)
            TableColumn("Items (lots)") { order in
                Text(verbatim: "\(order.items) (\(order.lots))")
            }
        }
        .navigationTitle("Picking")
    }
}
