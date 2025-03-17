
import SwiftUI


struct OrdersMainList: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    @Environment(OrderStore.self)
    var orderStore
    
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
            OrderDetailView(orderSummary: orderStore.orderSummary(forOrderWithId: orderId)!)
        }
        .toolbar {
            
            Button {
                actionPopoverPresented.toggle()
            } label: {
                Text("􀈟").padding(.horizontal)
            }
            .popover(isPresented: $actionPopoverPresented, arrowEdge: .bottom) {
                OrdersActionsSheet(orders: orders)
            }
            
            Button {
                Task { await refresh() }
            } label: {
                Text("􀅈").padding(.horizontal)
            }
            .disabled(refreshing)
        }
        .onChange(of: orderStore.orderSummaries, initial: true) {
            Task { await refresh() }
        }
    }
    
    
    func refresh() async {
        
        refreshing = true
        await app.refreshOrdersMainList()
        refreshing = false
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
    func itemView(_ order: OrderSummary) -> some View {
        
        OrdersMainListItem(order: order)
            .onTapGesture { nav.pushOrder(order.id) }
            .padding([.leading, .trailing])
    }
}



#Preview {
    
    let appController = AppController()
    let orderStore = appController.orderStore
    let navigationController = NavigationController()
    
    OrdersMainList()
        .environmentObject(appController)
        .environment(orderStore)
        .environment(navigationController)
}
