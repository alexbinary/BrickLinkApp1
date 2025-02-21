
import SwiftUI


struct OrdersListView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var ordersActiveNavigationPath: [OrderSummary.ID]
    
    @State var refreshing: Bool = false
    
    @State var searchText = ""
    
    
    var body: some View {
        
        let allOrders = appController.orderSummaries
            .filter { $0.matches(searchText) }
        
        ScrollView {
            
            LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                
                section(
                    header: "􁁿 In transit for 30+ days",
                    orders: allOrders
                        .filter { appController.orderBusinessStatus($0.id) == .inTransit && appController.orderChecklistUnchangedFor30Days($0.id) }
                        .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                )
                section(
                    header: OrderBusinessStatus.giveFeedback.descriptionWithPicto,
                    orders: allOrders
                        .filter { appController.orderBusinessStatus($0.id) == .giveFeedback }
                        .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                )
                section(
                    header: OrderBusinessStatus.validatePayment.descriptionWithPicto,
                    orders: allOrders
                        .filter { appController.orderBusinessStatus($0.id) == .validatePayment }
                        .sorted { $0.date > $1.date }
                )
                section(
                    header: OrderBusinessStatus.pickAndPack.descriptionWithPicto,
                    orders: allOrders
                        .filter { appController.orderBusinessStatus($0.id) == .pickAndPack }
                        .sorted { $0.lots < $1.lots }
                )
                section(
                    header: OrderBusinessStatus.ship.descriptionWithPicto,
                    orders: allOrders
                        .filter { appController.orderBusinessStatus($0.id) == .ship }
                        .sorted { $0.date > $1.date }
                )
                section(
                    header: OrderBusinessStatus.received.descriptionWithPicto,
                    orders: allOrders
                        .filter { appController.orderBusinessStatus($0.id) == .received }
                        .sorted { $0.dateStatusChanged < $1.dateStatusChanged }
                )
                section(
                    header: OrderBusinessStatus.inTransit.descriptionWithPicto,
                    orders: allOrders
                        .filter { appController.orderBusinessStatus($0.id) == .inTransit && !appController.orderChecklistUnchangedFor30Days($0.id) }
                        .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                )
                section(
                    header: "􀐫 Recently closed",
                    orders: allOrders
                        .filter { appController.orderBusinessStatus($0.id) == .closed && !appController.orderChecklistUnchangedFor30Days($0.id) }
                        .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                )
                
                let closedOrders = allOrders
                    .filter { appController.orderBusinessStatus($0.id) == .closed && appController.orderChecklistUnchangedFor30Days($0.id) }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                
                ForEach(closedOrders.grouppedByMonth, id: \.month) { item in
                    section(header: "􀤟 \(item.month)", orders: item.elements)
                }
            }
            .searchable(text: $searchText, prompt: "Search orders")
        }
        .navigationTitle("Orders")
        .navigationDestination(for: OrderSummary.ID.self) { orderId in
            OrderDetailView(orderId: orderId)
        }
        .toolbar {
            
            let ordersThatNeedCompletedAndGiveFeedback = allOrders
                .filter { appController.orderBusinessStatus($0.id) == .inTransit && appController.orderChecklistUnchangedFor30Days($0.id) }
                .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            
            if !ordersThatNeedCompletedAndGiveFeedback.isEmpty {
                Button {
                    Task {
                        for order in ordersThatNeedCompletedAndGiveFeedback {
                            await appController.updateOrderStatus(orderId: order.id, status: .completed)
                            await appController.postPraiseOrderFeedback(orderId: order.id)
                        }
                    }
                } label: {
                    Text("Complete & Give feedback (\(ordersThatNeedCompletedAndGiveFeedback.count))").padding(.horizontal)
                }
            }
            
            let ordersThatNeedGiveFeedback = allOrders
                .filter { appController.orderBusinessStatus($0.id) == .giveFeedback }
                .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            
            if !ordersThatNeedGiveFeedback.isEmpty {
                Button {
                    Task {
                        for order in ordersThatNeedGiveFeedback {
                            await appController.postPraiseOrderFeedback(orderId: order.id)
                        }
                    }
                } label: {
                    Text("Give feedback (\(ordersThatNeedGiveFeedback.count))").padding(.horizontal)
                }
            }
            
            let ordersToShipAndSendDriveThru = allOrders
                .filter {
                    appController.orderBusinessStatus($0.id) == .ship
                    && appController.orderChecklistStamping($0.id)
                    && appController.orderChecklistShippingTransaction($0.id)
                    && appController.orderChecklistTrackingNo($0.id)
                }
                .sorted { $0.date > $1.date }
            
            if !ordersToShipAndSendDriveThru.isEmpty {
                Button {
                    Task {
                        for order in ordersToShipAndSendDriveThru {
                            await appController.updateOrderStatus(orderId: order.id, status: .shipped)
                            await appController.sendDriveThru(orderId: order.id)
                        }
                    }
                } label: {
                    Text("Ship and send DT (\(ordersToShipAndSendDriveThru.count))").padding(.horizontal)
                }
            }
            
            Button {
                Task { await refresh() }
            } label: {
                Text("􀅈").padding(.horizontal)
            }
            .disabled(refreshing)
        }
        .onChange(of: appController.orderSummaries, initial: true) {
            Task { await refresh() }
        }
    }
    
    
    func refresh() async {
        
        refreshing = true
        
        await appController.reloadOrderSummaries()
        
        let allOrders = appController.orderSummaries
        
        let ordersThatNeedRefreshLaPosteTrackingStatus = allOrders
            .filter { appController.orderBusinessStatus($0.id) == .inTransit }
        
        for order in ordersThatNeedRefreshLaPosteTrackingStatus {
            await appController.reloadLaPosteTrackingStatus(forOrderWithId: order.id)
        }
        
        let ordersThatNeedRefreshFeedback = allOrders
            .filter { appController.orderBusinessStatus($0.id).isOneOf(.received, .giveFeedback) }
        
        for order in ordersThatNeedRefreshFeedback {
            await appController.reloadOrderFeedbacks(forOrderWithId: order.id)
        }
        
        refreshing = false
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
