
import SwiftUI


struct Order: Identifiable {
    
    let id: String
    let date: String
    let buyer: String
    let items: Int
    let lots: Int
    let grandTotal: Int
    let status: String
}


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
    let orders: [Order] = [
        Order(id: "#1", date: "Aug 14, 2024", buyer: "legofan_fr", items: 248, lots: 71, grandTotal: 1681, status: "COMPLETED"),
        Order(id: "#2", date: "Aug 14, 2024", buyer: "legofan_fr", items: 248, lots: 71, grandTotal: 1681, status: "COMPLETED"),
    ]
    
    
    var body: some View {
        
        NavigationSplitView {
            
            List {
                Label("Orders", systemImage: "list.bullet")
            }
            
        } detail: {
            
            Table(orders) {
                
                TableColumn("ID", value: \.id)
                TableColumn("Date", value: \.date)
                TableColumn("Buyer", value: \.buyer)
                TableColumn("Items (lots)") { order in
                    Text(verbatim: "\(order.items) (\(order.lots))")
                }
                TableColumn("Grand total") { order in
                    Text(verbatim: "\(Double(order.grandTotal)/100) €")
                }
                TableColumn("Shipping cost") { order in
                    
                    var value: Int = appController.shippingCost(forOrderWithId: order.id)
                    
                    let shippingCostBinding = Binding<Int> {
                        return value
                    } set: { newValue in
                        value = newValue
                    }
                    
                    TextField("Shipping cost", value: shippingCostBinding, format: .number)
                        .onSubmit {
                            appController.updateShippingCost(forOrderWithId: order.id, cost: value)
                        }
                }
                TableColumn("Status", value: \.status)
                
            }
                .navigationTitle("Orders")
        }
    }
}
