
import SwiftUI



struct OrdersDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderId: OrderDetails.ID?
    
    
    var body: some View {
            
        VStack {
            
            if let orderId = selectedOrderId {
                
                if let order = appController.orderDetails(forOrderWithId: orderId) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        TabView {
                            
                            ScrollView {
                                OrderDetailView(order: order)
                            }
                                .padding()
                                .tabItem {
                                    Text("Details & Actions")
                                }
                                .tag(0)
                            
                            OrderPickingView(orderId: orderId)
                                .tabItem {
                                    Text("Picking")
                                }
                                .tag(1)
                            
                            ScrollView {
                                OrderPackingAndShippingView(orderId: orderId)
                            }
                                .tabItem {
                                    Text("Packing & Shipping")
                                }
                                .tag(2)
                            
                            ScrollView {
                                OrderComptaView(order: order)
                            }
                                .padding()
                                .tabItem {
                                    Text("Compta")
                                }
                                .tag(3)
                        }
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
            await refreshOrder()
        }
        .onChange(of: selectedOrderId) { oldValue, newValue in
            Task {
                await refreshOrder()
            }
        }
    }
    
    
    func refreshOrder() async {
        
        guard let orderId = selectedOrderId else { return }
        
        await appController.forceRefreshOrder(orderId: orderId)
    }
}
