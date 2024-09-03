
import SwiftUI



struct OrdersDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderId: Order.ID?
    
    @State var order: Order? = nil
    @State var orderItems: [OrderItem] = []
    @State var orderFeedbacks: [Feedback] = []
    
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                if selectedOrderId == nil {
                    
                    Text("select an order")
                    
                } else if order == nil {
                    
                    Text("loading order...")
                    
                } else if let order = order {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        OrdersDetailDetailView(order: order, reloadOrder: {
                            Task {
                                await loadOrder()
                            }
                        })
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .task {
                await loadOrder()
            }
            .onChange(of: selectedOrderId) { oldValue, newValue in
                Task {
                    await loadOrder()
                }
            }
        }
    }
    
    
    func loadOrder() async {
        
        guard let orderId = selectedOrderId else { return }
        
        self.order = nil
        self.order = await appController.getOrder(orderId: orderId)
    }
}
