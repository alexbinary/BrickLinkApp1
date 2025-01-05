
import SwiftUI


struct OrdersListView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var ordersActiveNavigationPath: [OrderSummary.ID]
    
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                
                let allOrders = appController.orderSummaries
                
                let statuses: [OrderBusinessStatus] = [
                    .paymentPending,
                    .validatePayment,
                    .pickAndPack,
                    .ship,
                    .inTransit,
                    .giveFeedback,
                    .done,
                ]
                
                ForEach(statuses, id: \.self) { status in
                    
                    Group {
                        
                        let orders = {
                            var orders = allOrders.filter {
                                appController.orderBusinessStatus($0.id) == status
                            }
                            switch status {
                            case .pickAndPack:
                                orders = orders.sorted { $0.lots < $1.lots }
                            default:
                                orders = orders.sorted { $0.date > $1.date }
                            }
                            return orders
                        }()
                        
                        section(header: status.descriptionWithPicto, orders: orders)
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
            OrderDetailView(orderId: orderId)
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
            
            headerView(header, secondaryText: "\(orders.count) orders")
        }
    }
    
    
    @ViewBuilder
    func headerView(_ primaryText: String, secondaryText: String) -> some View {
        
        HStack(spacing: 24) {
            Text(primaryText).font(.title3)
            Text(secondaryText).foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.90))
    }
    
    
    @ViewBuilder
    func itemView(_ orderId: OrderSummary.ID) -> some View {
        
        OrderListItemView(orderId: orderId)
            .onTapGesture {
                ordersActiveNavigationPath.append(orderId)
            }
            .padding([.leading, .trailing])
    }
}
