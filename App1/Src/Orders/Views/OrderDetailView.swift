
import SwiftUI
import Core



struct OrderDetailView: View {
    
    
    @Environment(OrderStore.self)
    var orderStore
    
    
    let order: Order
    var orderDetails: OrderDetails? { orderStore.orderDetails(forOrderWithId: order.id) }
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    @State private var columnWidth: CGFloat?
    
    
    var body: some View {
        
        Group {
            
            if let _ = orderDetails {
                
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
                    
                    TabView(
//                        selection: .constant("shipping")
                    ) {
                        ScrollView { OrderDetailGeneralView(order) }
                            .padding()
                            .tabItem { Text("􀅴 General") }.tag("general")
                        
                        OrderDetailPickingView(order)
                            .tabItem { Text("􀈥 Picking") }.tag("picking")
                        
                        ScrollView { OrderDetailShippingView(order) }
                            .tabItem { Text("􀐚 Shipping") }.tag("shipping")
                        
                        ScrollView { OrderDetailFeedbackView(order) }
                            .tabItem { Text("􀉿 Feedback") }.tag("feedback")
                        
                        ScrollView { OrderDetailRefundView(order) }
                            .padding()
                            .tabItem { Text("􂈚 Refunds") }.tag("refunds")
                        
                        ScrollView { OrderDetailComptaView(order) }
                            .padding()
                            .tabItem { Text("􀖧 Compta") }.tag("compta")
                    }
                }
                
            } else {
                Text("Loading order...")
            }
        }
        .padding()
        .onChange(of: order.id, initial: true) {
            Task { await orderStore.forceRefreshOrder(orderId: order.id)}
        }
        .navigationTitle("Order \(order.id)")
    }
}
