
import SwiftUI


struct OrdersListView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var ordersActiveNavigationPath: [OrderSummary.ID]
    
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                
                let allOrders = appController.orderSummaries
                
                let sections: [(label: String, orders: [OrderSummary])] = [
                    (
                        label: "􀐫 In transit for 30+ days",
                        orders: allOrders
                            .filter { appController.orderBusinessStatus($0.id) == .inTransit && appController.orderChecklistUnchangedFor30Days($0.id) }
                            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                    ),
                    (
                        label: OrderBusinessStatus.giveFeedback.descriptionWithPicto,
                        orders: allOrders
                            .filter { appController.orderBusinessStatus($0.id) == .giveFeedback }
                            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                    ),
                    (
                        label: OrderBusinessStatus.validatePayment.descriptionWithPicto,
                        orders: allOrders
                            .filter { appController.orderBusinessStatus($0.id) == .validatePayment }
                            .sorted { $0.date > $1.date }
                    ),
                    (
                        label: OrderBusinessStatus.pickAndPack.descriptionWithPicto,
                        orders: allOrders
                            .filter { appController.orderBusinessStatus($0.id) == .pickAndPack }
                            .sorted { $0.lots < $1.lots }
                    ),
                    (
                        label: OrderBusinessStatus.ship.descriptionWithPicto,
                        orders: allOrders
                            .filter { appController.orderBusinessStatus($0.id) == .ship }
                            .sorted { $0.date > $1.date }
                    ),
                    (
                        label: OrderBusinessStatus.inTransit.descriptionWithPicto,
                        orders: allOrders
                            .filter { appController.orderBusinessStatus($0.id) == .inTransit && !appController.orderChecklistUnchangedFor30Days($0.id) }
                            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                    ),
                    (
                        label: "􀐫 Recently closed",
                        orders: allOrders
                            .filter { appController.orderBusinessStatus($0.id) == .closed && !appController.orderChecklistUnchangedFor30Days($0.id) }
                            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                    ),
                ]
                ForEach(sections, id: \.label) { s in
                    
                    section(header: s.label, orders: s.orders)
                }
                
                let closedOrders = allOrders
                    .filter {
                        appController.orderBusinessStatus($0.id) == .closed && appController.orderChecklistUnchangedFor30Days($0.id)
                    }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                
                ForEach(closedOrders.grouppedByMonth, id: \.month) { item in
                    
                    section(header: "􀤟 \(item.month)", orders: item.elements)
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
        
        if orders.count > 0 {
            
            Section {
                
                ForEach(orders) { order in
                    
                    itemView(order.id)
                }
                
                Color.clear.frame(width: 0, height: 24)
                
            } header: {
                
                headerView(header, secondaryText: "\(orders.count) orders")
            }
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
