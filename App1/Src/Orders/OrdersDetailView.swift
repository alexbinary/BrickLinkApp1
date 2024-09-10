
import SwiftUI



struct OrdersDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderId: OrderDetails.ID?
    
    @State var order: OrderDetails? = nil
    
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                if let orderId = selectedOrderId {
                    
                    if let order = appController.orderDetails(forOrderWithId: orderId) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            TabView {
                                
                                OrdersDetailDetailView(order: order)
                                    .padding()
                                    .tabItem {
                                        Text("Details & Actions")
                                    }
                                    .tag(0)
                                
                                OrdersDetailComptaView(order: order)
                                    .padding()
                                    .tabItem {
                                        Text("Compta")
                                    }
                                    .tag(1)
                            }
                            
                            Spacer()
                        }
                        
                    } else {
                        
                        Text("loading order...")
                    }
                    
                } else {
                    
                    Text("select an order")
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
        
        await appController.loadOrderDetailsIfMissing(forOrderWithId: orderId)
    }
}
