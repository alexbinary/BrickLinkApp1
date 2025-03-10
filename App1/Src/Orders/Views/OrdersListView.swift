
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
        
        let sections = app.ordersMainListSections(restrictingToOrdersMatching: searchText)
        let orders = sections.allOrders
        
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                ForEach(sections, id: \.header) { section in
                    
                    if section.orders.count > 0 {
                        sectionView(section)
                    }
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
            .filter { app.macroStatus(forOrderWithId: $0.id) == .inTransit }
        
        for order in ordersThatNeedRefreshLaPosteTrackingStatus {
            await app.reloadLaPosteTrackingStatus(forOrderWithId: order.id)
        }
        
        let ordersThatNeedRefreshFeedback = allOrders
            .filter { app.macroStatus(forOrderWithId: $0.id).isOneOf(.received, .giveFeedback) }
        
        for order in ordersThatNeedRefreshFeedback {
            await app.reloadOrderFeedbacks(forOrderWithId: order.id)
        }
        
        refreshing = false
    }
    
    
    @ViewBuilder
    func sectionView(_ section: OrdersMainListSection) -> some View {
            
        Section {
            
            ForEach(section.orders) { order in
                
                itemView(order.id)
            }
            
            Color.clear.frame(width: 0, height: 24)
            
        } header: {
            
            headerView(section.header, secondaryText: "\(section.orders.count) orders")
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
