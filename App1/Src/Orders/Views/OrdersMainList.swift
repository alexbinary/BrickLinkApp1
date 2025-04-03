
import SwiftUI
import Core



struct OrdersMainList: View {
    
    
    @Environment(OrderStore.self)
    var orderStore
    
    @Environment(NavigationController.self)
    var nav
    
    
    @State var refreshing: Bool = false
    @State var actionPopoverPresented: Bool = false
    @State var searchText = ""
    
    
    var body: some View {
        
        let sections = orderStore.ordersMainListSections(restrictingToOrdersMatching: searchText)
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
        .navigationDestination(for: Order.ID.self) { orderId in
            OrderDetailView(orderStore.order(withId: orderId)!)
        }
        .task { softRefresh() }
        .toolbar {
            
            Button {
                actionPopoverPresented.toggle()
            } label: {
                Text("􀈟").padding(.horizontal)
            }
            .popover(isPresented: $actionPopoverPresented, arrowEdge: .bottom) {
                OrdersActionsSheet(orders: orders)
            }
            
            Menu {
                Button("Soft refresh orders") { softRefresh() }
                Button("Hard refresh orders") { hardRefresh() }
                Button("Reload inventory") { /*TODO*/ }
            } label: { Text("􀅈").padding(.horizontal) }
            primaryAction: { softRefresh() }
        }
    }
    
    
    func softRefresh() {
        
        // TODO: invalidate orders and related data
        Task { await orderStore.refreshOrders(.refetchOnlyIfInvalidated) }
    }
    
    
    func hardRefresh() {
        
        Task { await orderStore.refreshOrders(.forceRefetch) }
    }
    
    
    @ViewBuilder
    func sectionView(_ section: OrdersMainListSection) -> some View {
            
        Section {
            ForEach(section.orders) { order in
                itemView(order)
            }
            Color.clear.frame(width: 0, height: 24)
            
        } header: {
            SectionHeader(section.header, secondaryText: "\(section.orders.count) orders")
        }
    }
    
    
    @ViewBuilder
    func itemView(_ order: Order) -> some View {
        
        OrdersMainListItem(order: order)
            .onTapGesture { nav.push(order) }
            .padding([.leading, .trailing])
    }
}



#Preview {
    
    let env = createEnv()
    
    OrdersMainList()
        .inject(env)
}
