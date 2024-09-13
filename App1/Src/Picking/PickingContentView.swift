
import SwiftUI


struct PickingContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var selectedOrderIds: Set<OrderSummary.ID>
    
    
    var body: some View {
        
        Table(of: OrderSummary.self, selection: $selectedOrderIds) {
            
            TableColumn("ID", value: \.id)
            
            TableColumn("Date") { order in
                Text(order.date, format: .dateTime)
            }
            
            TableColumn("Buyer", value: \.buyer)
            
            TableColumn("Items (lots)") { order in
                Text(verbatim: "\(order.items) (\(order.lots))")
            }
            
        } rows: {
            
            ForEach(appController.orderSummaries.grouppedByMonth, id: \.month) { item in
                
                Section(item.month) {
                    
                    ForEach(item.elements) { TableRow($0) }
                }
            }
        }
        .navigationTitle("Picking")
    }
}
