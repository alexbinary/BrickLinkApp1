
import SwiftUI


struct PickingDetailView: View {
    
    
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
                    
                    HeaderTitleView(label: "􁊇 Items")
                    
                    let pickedItems = appController.pickedItems(forOrderWithId: order.id)
                    
                    let pickedOrderItems = orderItems.filter {
                        pickedItems.contains($0.id)
                    }
                    let unpickedOrderItems = orderItems.filter {
                        !pickedItems.contains($0.id)
                    }
                    
                    HStack {
                        
                        Button {
                            for item in orderItems {
                                appController.pickItem(forOrderWithId: order.id, item: item.id)
                            }
                        } label: {
                            Text("Pick all")
                        }
                        
                        Button {
                            for item in orderItems {
                                appController.unpickItem(forOrderWithId: order.id, item: item.id)
                            }
                        } label: {
                            Text("Unpick all")
                        }
                    }
                    
                    Table(of: OrderItem.self) {
                        
                        TableColumn("Picked") { item in
                            let picked = appController.pickedItems(forOrderWithId: order.id).contains(item.id)
                            if picked {
                                Text("Picked")
                            } else {
                                Text("Not picked")
                            }
                            
                            Button {
                                if picked {
                                    appController.unpickItem(forOrderWithId: order.id, item: item.id)
                                } else {
                                    appController.pickItem(forOrderWithId: order.id, item: item.id)
                                }
                            } label: {
                                Text(picked ? "Unpick" : "Pick")
                            }

                        }
                        TableColumn("Condition", value: \.condition)
                        TableColumn("Color", value: \.color)
                        TableColumn("Ref", value: \.ref)
                        TableColumn("Name", value: \.name)
                        TableColumn("Comment", value: \.comment)
                        TableColumn("Location", value: \.location)
                        TableColumn("Quantity", value: \.quantity)
                        TableColumn("Left", value: \.quantityLeft)
                        
                    } rows : {
                        
                        Section("Unpicked") {
                            ForEach(unpickedOrderItems) { item in
                                TableRow(item)
                            }
                        }
                        Section("Picked") {
                            ForEach(pickedOrderItems) { item in
                                TableRow(item)
                            }
                        }
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
