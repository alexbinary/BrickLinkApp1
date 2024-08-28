
import SwiftUI


struct PickingDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderId: Order.ID?
    
    @State var order: Order? = nil
    @State var orderItems: [OrderItem] = []
    
    
    var body: some View {
        
        VStack {
            
            if selectedOrderId == nil {
                
                Text("select an order")
                
            } else if order == nil {
                
                Text("loading order...")
                
            } else {
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HeaderTitleView(label: "􁊇 Items")
                    
                    Table(orderItems) {
                        
                        TableColumn("Condition", value: \.condition)
                        TableColumn("Color", value: \.color)
                        TableColumn("Ref", value: \.ref)
                        TableColumn("Name", value: \.name)
                        TableColumn("Comment", value: \.comment)
                        TableColumn("Location", value: \.location)
                        TableColumn("Quantity", value: \.quantity)
                        TableColumn("Left", value: \.quantityLeft)
                    }
                    
                    Divider()
                    
                    Spacer()
                }
            }
        }
        .padding()
        .task {
            await loadOrder()
            await loadOrderItems()
        }
        .onChange(of: selectedOrderId) { oldValue, newValue in
            Task {
                await loadOrder()
                await loadOrderItems()
            }
        }
    }
    
    
    func loadOrder() async {
        
        guard let orderId = selectedOrderId else { return }
        
        self.order = nil
        self.order = await appController.getOrder(orderId: orderId)
    }
    
    
    func loadOrderItems() async {
        
        guard let orderId = selectedOrderId else { return }
        
        self.orderItems.removeAll()
        self.orderItems = await appController.getOrderItems(orderId: orderId)
    }
}
