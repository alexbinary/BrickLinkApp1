
import SwiftUI




struct OrderDetailPickingView: View {
    
    
    @Environment(OrderStore.self)
    var orderStore
    
    @Environment(InventoryStore.self)
    var inventoryStore
    
    @Environment(PickingStore.self)
    var pickingStore
    
    
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
                .font(.title3)
                .padding()
                .padding(.bottom, 12)
            
            TabView {
                
                if !nextOrderItemsToPick.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(nextOrderItemsToPick) { PickingItemView($0, button: .pick) }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀈥 Pick") }
                }
                
                if !pickedOrderItems.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(pickedOrderItems) { PickingItemView($0, button: .unpick) }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀐫 Picked") }
                }
            
                if !nextOrderItemsToVerify.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(nextOrderItemsToVerify) { PickingItemView($0, button: .verify) }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀁢 Verify") }
                }
                
                if !verifiedOrderItems.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(verifiedOrderItems) { PickingItemView($0, button: .unverify) }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀐫 Verified") }
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
