
import SwiftUI



struct OrderDetailPickingView: View {
    
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    @Environment(\.pickingStore)
    var pickingStore: PickingStoreProtocol!
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var pickedOrderItems: [OrderItem] { pickingStore.pickedOrderItems(for: order) }
    var verifiedOrderItems: [OrderItem] { pickingStore.verifiedOrderItems(for: order) }
    var nextOrderItemsToPick: [OrderItem] { pickingStore.nextOrderItemsToPick(for: order) }
    var nextOrderItemsToVerify: [OrderItem] { pickingStore.nextOrderItemsToVerify(for: order) }
    
    
    var body: some View {
            
        VStack(alignment: .leading) {
            
            PickingProgressView(order)
                .padding(.bottom, 12)
            
            TabView {
                
                let tabs: [(title: String, items: [OrderItem], button: ButtonType)] = [
                    ("􀈥 Pick", nextOrderItemsToPick, .pick),
                    ("􀐫 Picked", pickedOrderItems, .unpick),
                    ("􀁢 Verify", nextOrderItemsToVerify, .verify),
                    ("􀐫 Verified", verifiedOrderItems, .unverify)
                ]
                
                ForEach(tabs, id: \.title) { tab in
                    if !tab.items.isEmpty {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(tab.items) { item in
                                    VStack {
                                        Divider()
                                        PickingItemView(item, button: tab.button)
                                    }
                                }
                            }
                            .animation(.default, value: tab.items)
                            .padding()
                        }
                        .tabItem { Text(tab.title) }
                    }
                }
            }
        }
        .padding()
        .task { await orderStore.softRefreshItems(for: order) }
        .task { await inventoryStore.softRefreshInventories() }
    }
}



#Preview {
    
    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    OrderDetailPickingView(order)
        .inject(env)
}
