
import SwiftUI


struct PickingDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderId: Order.ID?
    
    @State var order: Order? = nil
    @State var orderItems: [OrderItem] = []
    
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                if selectedOrderId == nil {
                    
                    Text("select an order")
                    
                } else if order == nil {
                    
                    Text("loading order...")
                    
                } else if let order = order {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􁊇 Items")
                        
                        let pickedItems = appController.pickedItems(forOrderWithId: order.id)
                        let verifiedItems = appController.verifiedItems(forOrderWithId: order.id)
                        
                        let orderItemsToPick = orderItems
                            .filter { !pickedItems.contains($0.id) }
                            .sorted { $0.location < $1.location }
                        let orderItemsToVerify = orderItems
                            .filter { pickedItems.contains($0.id) && !verifiedItems.contains($0.id) }
                            .sorted { $0.location < $1.location }
                        let orderItemsPickedAndVerified = orderItems
                            .filter { pickedItems.contains($0.id) && verifiedItems.contains($0.id) }
                            .sorted { $0.location < $1.location }
                        
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
                            
                            Button {
                                for item in orderItems {
                                    appController.verifyItem(forOrderWithId: order.id, item: item.id)
                                }
                            } label: {
                                Text("Verify all")
                            }
                            
                            Button {
                                for item in orderItems {
                                    appController.unverifyItem(forOrderWithId: order.id, item: item.id)
                                }
                            } label: {
                                Text("Unverify all")
                            }
                        }
                        
                        Text("To pick").font(.title2)
                        
                        Table(orderItemsToPick) {
                            
                            TableColumn("Status") { item in
                                
                                let picked = appController.pickedItems(forOrderWithId: order.id).contains(item.id)
                                let verified = appController.verifiedItems(forOrderWithId: order.id).contains(item.id)
                                
                                if !picked {
                                    Button {
                                        appController.pickItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Pick")
                                    }
                                }
                                
                                if picked && !verified {
                                    
                                    Button {
                                        appController.unpickItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Unpick")
                                    }
                                    Button {
                                        appController.verifyItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Verify")
                                    }
                                }
                                
                                if picked && verified {
                                    
                                    Button {
                                        appController.unpickItem(forOrderWithId: order.id, item: item.id)
                                        appController.unverifyItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Unpick")
                                    }
                                    Button {
                                        appController.unverifyItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Unverify")
                                    }
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
                        }
                        .frame(minHeight: 400)
                        
                        Text("To verify").font(.title2)
                        
                        Table(orderItemsToVerify) {
                            
                            TableColumn("Status") { item in
                                
                                let picked = appController.pickedItems(forOrderWithId: order.id).contains(item.id)
                                let verified = appController.verifiedItems(forOrderWithId: order.id).contains(item.id)
                                
                                if !picked {
                                    Button {
                                        appController.pickItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Pick")
                                    }
                                }
                                
                                if picked && !verified {
                                    
                                    Button {
                                        appController.unpickItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Unpick")
                                    }
                                    Button {
                                        appController.verifyItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Verify")
                                    }
                                }
                                
                                if picked && verified {
                                    
                                    Button {
                                        appController.unpickItem(forOrderWithId: order.id, item: item.id)
                                        appController.unverifyItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Unpick")
                                    }
                                    Button {
                                        appController.unverifyItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Unverify")
                                    }
                                }
                            }
                            TableColumn("Condition", value: \.condition)
                            TableColumn("Color", value: \.color)
                            TableColumn("Ref", value: \.ref)
                            TableColumn("Name", value: \.name)
                            TableColumn("Comment", value: \.comment)
                            TableColumn("Quantity", value: \.quantity)
                        }
                        .frame(minHeight: 400)
                        
                        Text("Picked and verified").font(.title2)
                        
                        Table(orderItemsPickedAndVerified) {
                            
                            TableColumn("Status") { item in
                                
                                let picked = appController.pickedItems(forOrderWithId: order.id).contains(item.id)
                                let verified = appController.verifiedItems(forOrderWithId: order.id).contains(item.id)
                                
                                if !picked {
                                    Button {
                                        appController.pickItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Pick")
                                    }
                                }
                                
                                if picked && !verified {
                                    
                                    Button {
                                        appController.unpickItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Unpick")
                                    }
                                    Button {
                                        appController.verifyItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Verify")
                                    }
                                }
                                
                                if picked && verified {
                                    
                                    Button {
                                        appController.unpickItem(forOrderWithId: order.id, item: item.id)
                                        appController.unverifyItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Unpick")
                                    }
                                    Button {
                                        appController.unverifyItem(forOrderWithId: order.id, item: item.id)
                                    } label: {
                                        Text("Unverify")
                                    }
                                }
                            }
                            TableColumn("Condition", value: \.condition)
                            TableColumn("Color", value: \.color)
                            TableColumn("Ref", value: \.ref)
                            TableColumn("Name", value: \.name)
                            TableColumn("Comment", value: \.comment)
                            TableColumn("Quantity", value: \.quantity)
                        }
                        .frame(minHeight: 400)
                        
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
