
import SwiftUI
import HTMLEntities



struct OrderDetailPickingView: View {
    
    
    @Environment(OrderStore.self)
    var orderStore
    
    @Environment(InventoryStore.self)
    var inventoryStore
    
    @Environment(PickingStore.self)
    var pickingStore
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var pickedOrderItems: [OrderItem] { pickingStore.pickedOrderItems(forOrderWithId: order.id) }
    var verifiedOrderItems: [OrderItem] { pickingStore.verifiedOrderItems(forOrderWithId: order.id) }
    var nextOrderItemsToPick: [OrderItem] { pickingStore.nextOrderItemsToPick(forOrderWithId: order.id) }
    var nextOrderItemsToVerify: [OrderItem] { pickingStore.nextOrderItemsToVerify(forOrderWithId: order.id) }
    
    
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
        .onChange(of: order, initial: true) { Task {
            await orderStore.loadOrderItemsIfMissing(forOrderWithId: order.id)
        }}
        .onAppear { Task {
            await inventoryStore.reloadInventories()
        }}
    }
}



#Preview {
    
    let env = createEnv()
    let order = env.stores.order.orderDetails.first!
    
    OrderDetailPickingView(order)
        .inject(env)
}
