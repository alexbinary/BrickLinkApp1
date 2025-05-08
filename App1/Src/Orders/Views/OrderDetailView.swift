
import SwiftUI



struct OrderDetailView: View {
    
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    @Environment(\.navigationController)
    var nav: NavigationControllerProtocol!
    
    
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
            
            let navOrderDetailTabBinding = Binding {
                nav.orderDetailTab
            } set: {
                nav.orderDetailTab = $0
            }
            TabView(selection: navOrderDetailTabBinding) {
                
                ScrollView {
                    HStack {
                        OrderDetailPaymentView(order)
                        Spacer()
                    }
                }
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



#Preview {
    
    let order = Order.previewOrderWith(
        subTotal: 42,
        grandTotal: 12
    )
    let details = OrderDetails.previewOrderDetailsWith(
        shippingCost: 34
    )
    
    OrderDetailView(order)
        .padding()
        .frame(width: 1200, height: 600)
        .previewEnv(
            orderStore: PreviewOrderStore(
                detailsForOrder: details
            )
        )
}
