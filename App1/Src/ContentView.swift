
import SwiftUI


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedOrderId: Order.ID? = nil
    @State var selectedOrder: Order? = nil
    @State var orderItems: [OrderItem] = []
    
    
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
                
                if selectedOrderId == nil {
                    
                    Text("select an order")
                    
                } else if selectedOrder == nil {
                    
                    Text("loading order...")
                    
                } else if let order = selectedOrder {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􁊇 Update status")
                        
                        let statuses = ["PAID", "PACKED", "SHIPPED", "COMPLETED"]
                        
                        HStack {
                            ForEach(statuses, id: \.self) { status in
                                Button {
                                    Task {
                                        await appController.updateOrderStatus(orderId: order.id, status: status)
                                    }
                                } label: {
                                    Text(status)
                                }
                            }
                        }
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Drive thru")
                        
                        if order.driveThruSent {
                            Text("Drive through sent")
                        } else {
                            Text("Drive through not sent")
                        }
                        
                        Button {
                            Task {
                                await appController.sendDriveThru(orderId: order.id)
                            }
                        } label: {
                            Text("Send drive thru")
                        }
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Items")
                        
                        Table(orderItems) {
                            
                            TableColumn("Condition", value: \.condition)
                            TableColumn("Color", value: \.color)
                            TableColumn("Ref", value: \.ref)
                            TableColumn("Name", value: \.name)
                            TableColumn("Comment", value: \.comment)
                            TableColumn("Location", value: \.location)
                            TableColumn("Quantity", value: \.quantity)
                            TableColumn("Left", value: \.quantityLeft)
                        }
                        
                        Divider()
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .onChange(of: selectedOrderId) { oldValue, newValue in
                Task {
                    await loadOrder()
                    await loadOrderItems()
                }
            }
        }
    }
    
    
    func loadOrder() async {
        
        guard let orderId = selectedOrderId else { return }
        
        self.selectedOrder = nil
        self.selectedOrder = await appController.getOrder(orderId: orderId)
    }
    
    
    func loadOrderItems() async {
        
        guard let orderId = selectedOrderId else { return }
        
        self.orderItems.removeAll()
        self.orderItems = await appController.getOrderItems(orderId: orderId)
    }
}
