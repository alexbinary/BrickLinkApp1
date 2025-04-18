
import SwiftUI



struct OrderDetailView: View {
    
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    @Environment(NavigationController.self)
    var nav
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    @State var columnWidth: CGFloat?
    
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            
            VStack(alignment: .leading, spacing: 12) {
                
                OrderIdentityView(order)
                    .padding()
                    .equalWidths()
                    .frame(width: columnWidth, alignment: .leading)
                    .roundedContainer(style: .primary)
                    .padding(.top, 10)
                
                OrderChecklistView(order)
                    .padding()
                    .equalWidths()
                    .frame(width: columnWidth, alignment: .leading)
                    .roundedContainer(style: .primary)
            }
            .equalWidths($columnWidth)
            
            @Bindable var nav = nav
            
            TabView(selection: $nav.orderDetailTab) {
                
                ScrollView { OrderDetailPaymentView(order) }
                    .padding()
                    .tabItem { Text("􀖧 Payment") }.tag(OrderDetailTab.payment)
                
                OrderDetailPickingView(order)
                    .tabItem { Text("􀈥 Picking") }.tag(OrderDetailTab.picking)
                
                ScrollView { OrderDetailShippingView(order) }
                    .tabItem { Text("􀐚 Shipping") }.tag(OrderDetailTab.shipping)
                
                ScrollView { OrderDetailFeedbackView(order) }
                    .tabItem { Text("􀉿 Feedback") }.tag(OrderDetailTab.feedback)
                
                ScrollView { OrderDetailRefundView(order) }
                    .padding()
                    .tabItem { Text("􂈚 Refunds") }.tag(OrderDetailTab.refunds)
                
                ScrollView { OrderDetailComptaView(order) }
                    .padding()
                    .tabItem { Text("􀖧 Compta") }.tag(OrderDetailTab.compta)
            }
            
        }
        .padding()
        .navigationTitle("Order \(order.id)")
    }
}
