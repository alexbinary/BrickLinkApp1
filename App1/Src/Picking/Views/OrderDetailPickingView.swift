
import SwiftUI
import HTMLEntities



struct OrderDetailPickingView: View {
    
    
    @Environment(OrderStore.self)
    var orderStore
    
    @Environment(InventoryController.self)
    var inventoryController
    
    @Environment(PickingController.self)
    var pickingController
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var pickedOrderItems: [OrderItem] { pickingController.pickedOrderItems(forOrderWithId: order.id) }
    var verifiedOrderItems: [OrderItem] { pickingController.verifiedOrderItems(forOrderWithId: order.id) }
    var nextOrderItemsToPick: [OrderItem] { pickingController.nextOrderItemsToPick(forOrderWithId: order.id) }
    var nextOrderItemsToVerify: [OrderItem] { pickingController.nextOrderItemsToVerify(forOrderWithId: order.id) }
    
    
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
        .onChange(of: order, initial: true) {
            Task { await orderStore.loadOrderItemsIfMissing(forOrderWithId: order.id) }
        }
        .onAppear {
            Task { await inventoryController.reloadInventories() }
        }
    }
}



#Preview {
    
    let controllers = AppController.createControllers()
    let orderStore = controllers.orderStore
    let inventoryController = controllers.inventoryController
    let pickingController = controllers.pickingController
    
    let order = orderStore.orderDetails.first!
    
    OrderDetailPickingView(order)
        .environment(orderStore)
        .environment(inventoryController)
        .environment(pickingController)
}
