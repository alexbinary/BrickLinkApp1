
import SwiftUI
import HTMLEntities



struct OrderDetailPickingView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    
    var body: some View {
            
        VStack(alignment: .leading) {
            
            OrderPickingProgressView(order)
                .font(.title3)
                .padding()
                .padding(.bottom, 12)
            
            TabView {
                
                if !nextOrderItemsToPick.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(nextOrderItemsToPick) { PickingItemView($0, buttons: [.pick]) }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀈥 Pick") }
                }
                
                if !pickedOrderItems.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(pickedOrderItems.reversed()) { PickingItemView($0, buttons: [.unpick]) }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀐫 Picked") }
                }
            
                if !nextOrderItemsToVerify.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(nextOrderItemsToVerify) { PickingItemView($0, buttons: [.verify]) }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀁢 Verify") }
                }
                
                if !verifiedOrderItems.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(verifiedOrderItems.reversed()) { PickingItemView($0, buttons: [.unverify]) }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀐫 Verified") }
                }
            }
        }
        .padding()
        .onChange(of: order, initial: true) {
            Task { await app.loadOrderItemsIfMissing(forOrderWithId: order.id) }
        }
        .onAppear {
            Task { await app.reloadInventories() }
        }
    }
    
    
    var orderItems: [OrderItem] {
        app.orderItems(forOrderWithId: order.id)
    }
    
    var pickedOrderItemIds: [OrderItem.ID] {
        app.pickedItems(forOrderWithId: order.id)
    }
    
    var pickedOrderItems: [OrderItem] {
        pickedOrderItemIds.map { id in orderItems.first { $0.id == id }! }
    }
    
    var verifiedOrderItemIds: [OrderItem.ID] {
        app.verifiedItems(forOrderWithId: order.id)
    }
    
    var verifiedOrderItems: [OrderItem] {
        verifiedOrderItemIds.map { id in orderItems.first { $0.id == id }! }
    }
    
    
    var nextOrderItemsToPick: [OrderItem] { orderItems
        .filter { !pickedOrderItemIds.contains($0.id) }
        .sorted { $0.location < $1.location }
    }
    var nextOrderItemsToVerify: [OrderItem] { orderItems
        .filter { pickedOrderItemIds.contains($0.id) && !verifiedOrderItemIds.contains($0.id) }
        .sorted { a, b in a.condition == "N" }
    }
}
