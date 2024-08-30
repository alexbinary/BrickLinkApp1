
import SwiftUI


struct PickingDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderIds: Set<Order.ID>
    
    @State var orderItems: [OrderItem] = []
    
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                if selectedOrderIds.isEmpty {
                    
                    Text("select an order")
                    
                } else if orderItems.isEmpty {
                    
                    Text("loading order...")
                    
                } else {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        PickingItemsView(selectedOrderIds: selectedOrderIds, orderItems: orderItems)
                        
                        Divider()
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .task {
                await loadOrderItems()
            }
            .onChange(of: selectedOrderIds) { oldValue, newValue in
                Task {
                    await loadOrderItems()
                }
            }
        }
    }
    
    
    func loadOrderItems() async {
        
        self.orderItems.removeAll()
        
        for orderId in selectedOrderIds {
            self.orderItems.append(contentsOf: await appController.getOrderItems(orderId: orderId))
        }
    }
}
