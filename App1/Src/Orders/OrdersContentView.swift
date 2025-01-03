
import SwiftUI


struct OrdersContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var ordersActiveNavigationPath: [OrderSummary.ID]
    
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                
                let allOrders = appController.orderSummaries
                
                Group {
                    section(header: "􁕍 Validate payment", orders: allOrders.filter {
                        appController.orderBusinessStatus($0.id) == .validatePayment
                    })
                }
                
                Group {
                    section(header: "􀈥 Ready to pick", orders: allOrders.filter {
                        appController.orderBusinessStatus($0.id) == .readyForPicking
                    })
                }
                
                Group {
                    section(header: "􀐚 Ready to ship", orders: allOrders.filter {
                        appController.orderBusinessStatus($0.id) == .readyToShip
                    })
                }
                
                Group {
                    section(header: "􁕍 Validate shipping", orders: allOrders.filter {
                        appController.orderBusinessStatus($0.id) == .validateShipping
                    })
                }
                
                Group {
                    section(header: "􀐛 Received", orders: allOrders.filter {
                        appController.orderBusinessStatus($0.id) == .received
                    })
                }
                
                Group {
                    section(header: "􀖧 Pending payment", orders: allOrders.filter {
                        appController.orderBusinessStatus($0.id) == .pendingPayment
                    })
                }
                
                Group {
                    section(header: "􁁾 In transit", orders: allOrders.filter {
                        appController.orderBusinessStatus($0.id) == .inTransit
                    })
                }
                
                Group {
                    section(header: "􁙕 Done", orders: allOrders.filter {
                        appController.orderBusinessStatus($0.id) == .done
                    })
                }
                
                Section {
                    
                    let closedOrders = allOrders.filter {
                        appController.orderBusinessStatus($0.id) == .closed
                    }
                    ForEach(closedOrders.grouppedByMonth, id: \.month) { item in
                        
                        section(header: "item.month", orders: item.elements)
                    }
                    
                } header: {
                    headerView("􀹴 Closed")
                }
            }
        }
        .navigationTitle("Orders")
        .navigationDestination(for: OrderSummary.ID.self) { orderId in
            OrdersDetailView(orderId: orderId)
        }
        .toolbar {
            
            Button {
                Task {
                    await appController.reloadOrderSummaries()
                    await appController.refreshAllOrders()
                }
            } label: {
                Text("Refresh everything")
            }
        }
    }
    
    
    @ViewBuilder
    func section(header: String, orders: [OrderSummary]) -> some View {
        
        Section {
            
            if orders.isEmpty {
                
                Text("")
                
            } else {
                
                ForEach(orders) { order in
                    
                    itemView(order.id)
                }
            }
            
            Color.clear.frame(width: 0, height: 24)
            
        } header: {
            
            headerView(header)
        }
    }
    
    
    @ViewBuilder
    func headerView(_ text: String) -> some View {
        
        HStack {
            Text(text).font(.title3)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.90))
    }
    
    
    @ViewBuilder
    func itemView(_ orderId: OrderSummary.ID) -> some View {
        
        OrderCardView(orderId: orderId, disclosureIndicatorVisible: true)
            .onTapGesture {
                ordersActiveNavigationPath.append(orderId)
            }
            .padding([.leading, .trailing])
    }
}
