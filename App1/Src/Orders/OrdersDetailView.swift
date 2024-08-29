
import SwiftUI


struct OrdersDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderId: Order.ID?
    
    @State var order: Order? = nil
    @State var orderItems: [OrderItem] = []
    
    
    var body: some View {
        
        VStack {
            
            if selectedOrderId == nil {
                
                Text("select an order")
                
            } else if order == nil {
                
                Text("loading order...")
                
            } else if let order = order {
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HeaderTitleView(label: "􁊇 Update status")
                    
                    let statuses = ["PAID", "PACKED", "SHIPPED", "COMPLETED"]
                    
                    HStack {
                        ForEach(statuses, id: \.self) { status in
                            Button {
                                Task {
                                    await appController.updateOrderStatus(orderId: order.id, status: status)
                                    await loadOrder()
                                }
                            } label: {
                                Text(status)
                                    .fontWeight(order.status == status ? .bold : .regular)
                            }
                        }
                    }
                    
                    Divider()
                    
                    HeaderTitleView(label: "􁊇 Tracking")
                    
                    if order.trackingNo?.isEmpty ?? true {
                        Text("Tracking no not set")
                    } else {
                        Text("Tracking no set")
                    }
                    
                    var trackingNoEditValue = order.trackingNo
                    
                    let trackingNoBinding = Binding<String> {
                        return trackingNoEditValue ?? ""
                    } set: { newValue in
                        trackingNoEditValue = newValue
                    }
                    
                    TextField("Tracking No", text: trackingNoBinding)
                        .onSubmit {
                            Task {
                                await appController.updateTrackingNo(forOrderWithId: order.id, trackingNo: trackingNoEditValue ?? "")
                                await loadOrder()
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
                            await loadOrder()
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
        .task {
            await loadOrder()
            await loadOrderItems()
        }
        .onChange(of: selectedOrderId) { oldValue, newValue in
            Task {
                await loadOrder()
                await loadOrderItems()
            }
        }
    }
    
    
    func loadOrder() async {
        
        guard let orderId = selectedOrderId else { return }
        
        self.order = nil
        self.order = await appController.getOrder(orderId: orderId)
    }
    
    
    func loadOrderItems() async {
        
        guard let orderId = selectedOrderId else { return }
        
        self.orderItems.removeAll()
        self.orderItems = await appController.getOrderItems(orderId: orderId)
    }
}
