
import SwiftUI


struct Order: Identifiable {
    
    let id: String
    let date: String
    let buyer: String
    let items: Int
    let lots: Int
    let grandTotal: Float
    let status: String
}


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
    var body: some View {
        
        NavigationSplitView {
            
            List {
                Label("Orders", systemImage: "list.bullet")
            }
            
        } detail: {
            
            Table(appController.orders) {
                
                TableColumn("ID", value: \.id)
                TableColumn("Date", value: \.date)
                TableColumn("Buyer", value: \.buyer)
                TableColumn("Items (lots)") { order in
                    Text(verbatim: "\(order.items) (\(order.lots))")
                }
                TableColumn("Grand total") { order in
                    Text(verbatim: "\(order.grandTotal) €")
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
            .task {
                await appController.reloadOrders()
            }
            .navigationTitle("Orders")
        }
    }
}
