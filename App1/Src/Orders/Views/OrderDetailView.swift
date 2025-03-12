
import SwiftUI



struct OrderDetailView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    
    let order: OrderDetails
    var orderSummary: OrderSummary { app.orderSummary(forOrderWithId: order.id)! }
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    @State private var columnWidth: CGFloat?
    
    
    var body: some View {
            
        VStack {
            
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
                
                TabView {
                    
                    OrderGeneralView(order: order)
                    .padding()
                    .tabItem { Text("􀅴 General") }.tag("general")
                    
                    OrderPickingView(orderId: order.id)
                    .tabItem { Text("􀈥 Picking") } .tag("picking")
                    
                    ScrollView { OrderShippingView(orderId: order.id) }
                    .tabItem { Text("􀐚 Shipping") } .tag("shipping")
                    
                    ScrollView { OrderFeedbackView(orderId: order.id) }
                    .tabItem { Text("􀉿 Feedback") } .tag("feedback")
                    
                    ScrollView { OrderRefundView(order: order) }
                    .padding()
                    .tabItem { Text("􂈚 Refunds") } .tag("refunds")
                    
                    ScrollView { OrderComptaView(order: order) }
                    .padding()
                    .tabItem { Text("􀖧 Compta") } .tag("compta")
                }
            }
        }
        .padding()
        .onChange(of: order, initial: true) { Task { await app.forceRefreshOrder(orderId: order.id)} }
        .navigationTitle("Order \(order.id)")
    }
}



extension View {
    
    
    @ViewBuilder func checklistTitle() -> some View {
        
        self.font(.title3).opacity(0.5)
    }
}
