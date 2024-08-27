
import SwiftUI


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedOrderId: Order.ID? = nil
    
    
    
    
    var body: some View {
        
        NavigationSplitView {
            
            List {
                Label("Orders", systemImage: "list.bullet")
            }
            
        } content : {
            
            Table(appController.orders, selection: $selectedOrderId) {
                
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
            
            VStack {
                
                if let orderId = selectedOrderId {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􁊇 Update status")
                        
                        let statuses = ["PAID", "PACKED", "SHIPPED", "COMPLETED"]
                        
                        HStack {
                            ForEach(statuses, id: \.self) { status in
                                Button {
                                    Task {
                                        await appController.updateOrderStatus(orderId: orderId, status: status)
                                    }
                                } label: {
                                    Text(status)
                                }
                            }
                        }
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Drive thru")
                        
                        Button {
                            Task {
                                await appController.sendDriveThru(orderId: orderId)
                            }
                        } label: {
                            Text("Send drive thru")
                        }
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Items")
                        
                        
                        
                        Divider()
                        
                        Spacer()
                    }
                    
                } else {
                    
                    Text("select an order")
                }
            }
            .padding()
        }
    }
}
