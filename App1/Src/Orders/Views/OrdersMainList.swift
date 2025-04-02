
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
        .task {
            await orderStore.refreshOrders(.refetchOnlyIfInvalidated)
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
                Task { await orderStore.refreshOrders(.forceRefetch) }
            } label: {
                Text("􀅈").padding(.horizontal)
            }
        }
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
