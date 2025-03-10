
import SwiftUI


struct OrdersListView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    @Environment(NavigationController.self)
    var nav
    
    @State var refreshing: Bool = false
    @State var actionPopoverPresented: Bool = false
    @State var searchText = ""
    
    
    var body: some View {
        
        let orders = app.orderSummaries(matching: searchText)
        
        ScrollView {
            
            LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                
                section(
                    header: "􁁿 In transit for 30+ days",
                    orders: orders
                        .filter { app.orderBusinessStatus($0.id) == .inTransit && app.orderChecklistUnchangedFor30Days($0.id) }
                        .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                )
                section(
                    header: OrderBusinessStatus.giveFeedback.descriptionWithPicto,
                    orders: orders
                        .filter { app.orderBusinessStatus($0.id) == .giveFeedback }
                        .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                )
                section(
                    header: OrderBusinessStatus.validatePayment.descriptionWithPicto,
                    orders: orders
                        .filter { app.orderBusinessStatus($0.id) == .validatePayment }
                        .sorted { $0.date > $1.date }
                )
                section(
                    header: OrderBusinessStatus.pickAndPack.descriptionWithPicto,
                    orders: orders
                        .filter { app.orderBusinessStatus($0.id) == .pickAndPack }
                        .sorted { $0.lots < $1.lots }
                )
                section(
                    header: OrderBusinessStatus.ship.descriptionWithPicto,
                    orders: orders
                        .filter { app.orderBusinessStatus($0.id) == .ship }
                        .sorted { $0.date > $1.date }
                )
                section(
                    header: OrderBusinessStatus.received.descriptionWithPicto,
                    orders: orders
                        .filter { app.orderBusinessStatus($0.id) == .received }
                        .sorted { $0.dateStatusChanged < $1.dateStatusChanged }
                )
                section(
                    header: OrderBusinessStatus.inTransit.descriptionWithPicto,
                    orders: orders
                        .filter { app.orderBusinessStatus($0.id) == .inTransit && !app.orderChecklistUnchangedFor30Days($0.id) }
                        .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                )
                section(
                    header: "􀐫 Recently closed",
                    orders: orders
                        .filter { app.orderBusinessStatus($0.id) == .closed && !app.orderChecklistUnchangedFor30Days($0.id) }
                        .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
                )
                
                let closedOrders = orders
                    .filter { app.orderBusinessStatus($0.id) == .closed && app.orderChecklistUnchangedFor30Days($0.id) }
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
            
            Button {
                actionPopoverPresented.toggle()
            } label: {
                Text("􀈟").padding(.horizontal)
            }
            .popover(isPresented: $actionPopoverPresented, arrowEdge: .bottom) {
                OrdersActionsView(allOrders: orders)
            }
            
            Button {
                Task { await refresh() }
            } label: {
                Text("􀅈").padding(.horizontal)
            }
            .disabled(refreshing)
        }
        .onChange(of: app.orderSummaries, initial: true) {
            Task { await refresh() }
        }
    }
    
    
    func refresh() async {
        
        refreshing = true
        
        await app.reloadOrderSummaries()
        
        let allOrders = app.orderSummaries
        
        let ordersThatNeedRefreshLaPosteTrackingStatus = allOrders
            .filter { app.orderBusinessStatus($0.id) == .inTransit }
        
        for order in ordersThatNeedRefreshLaPosteTrackingStatus {
            await app.reloadLaPosteTrackingStatus(forOrderWithId: order.id)
        }
        
        let ordersThatNeedRefreshFeedback = allOrders
            .filter { app.orderBusinessStatus($0.id).isOneOf(.received, .giveFeedback) }
        
        for order in ordersThatNeedRefreshFeedback {
            await app.reloadOrderFeedbacks(forOrderWithId: order.id)
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
                nav.pushOrder(orderId)
            }
            .padding([.leading, .trailing])
    }
}
