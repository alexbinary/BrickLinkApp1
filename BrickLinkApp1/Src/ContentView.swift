
import SwiftUI


struct Order: Identifiable {
    
    let id: String
    let date: Date
    let buyer: String
    let items: Int
    let lots: Int
    let grandTotal: Float
    let status: String
}


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedOrderID: Order.ID? = nil
    
    
    var body: some View {
        
        NavigationSplitView {
            
            List {
                Label("Orders", systemImage: "list.bullet")
            }
            
        } content : {
            
            Table(appController.orders, selection: $selectedOrderID) {
                
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
                    
                    var value = appController.shippingCost(forOrderWithId: order.id)
                    
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
                
            }
            .task {
                await appController.reloadOrders()
            }
            .navigationTitle("Orders")
            
        } detail: {
            
            if let orderID = selectedOrderID {
                
                Text("\(orderID)")
                
                let statuses = ["PAID", "PACKED", "SHIPPED", "COMPLETED"]
                
                ForEach(statuses, id: \.self) { status in
                
                    Button {
                        Task {
                            await appController.updateOrderStatus(orderId: orderID, status: status)
                        }
                    } label: {
                        Text(status)
                    }

                }
                
            } else {
                
                Text("select an order")
            }
        }
    }
}
