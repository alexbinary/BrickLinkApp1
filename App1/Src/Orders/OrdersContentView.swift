
import SwiftUI


struct OrdersContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var ordersActiveNavigationPath: [OrderSummary.ID]
    
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                
                let allOrders = appController.orderSummaries
                
                let statuses: [OrderBusinessStatus] = [
                    .validatePayment,
                    .pickAndPack,
                    .ship,
                    .validateShipping,
                    .giveFeedback,
                    .paymentPending,
                    .inTransit,
                    .done,
                ]
                
                ForEach(statuses, id: \.self) { status in
                    
                    Group {
                        section(header: status.descriptionWithPicto, orders: allOrders.filter {
                            appController.orderBusinessStatus($0.id) == status
                        })
                    }
                }
                
                let closedOrders = allOrders.filter {
                    appController.orderBusinessStatus($0.id) == .closed
                }
                ForEach(closedOrders.grouppedByMonth, id: \.month) { item in
                    
                    section(header: "\(OrderBusinessStatus.closed.descriptionWithPicto) - \(item.month)", orders: item.elements)
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
        
        OrderCardView(orderId: orderId)
            .onTapGesture {
                ordersActiveNavigationPath.append(orderId)
            }
            .padding([.leading, .trailing])
    }
}
