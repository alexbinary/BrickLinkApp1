
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
                
                if !orderItemsToPick.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(orderItemsToPick) { PickingItemView($0, buttons: [.pick]) }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀈥 Pick") }
                }
                
                if !pickedItems.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(pickedItems.reversed(), id: \.self) { item in
                                PickingItemView(orderItems.first { $0.id == item }!, buttons: [.unpick])
                            }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀐫 Picked") }
                }
            
                if !orderItemsToVerify.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(orderItemsToVerify) { PickingItemView($0, buttons: [.verify]) }
                        }
                    }
                    .padding()
                    .tabItem { Text("􀁢 Verify") }
                }
                
                if !verifiedItems.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(verifiedItems.reversed(), id: \.self) { item in
                                PickingItemView(orderItems.first { $0.id == item }!, buttons: [.unverify])
                            }
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
    
    var pickedItems: [OrderItem.ID] {
        app.pickedItems(forOrderWithId: order.id)
    }
    
    var verifiedItems: [OrderItem.ID] {
        app.verifiedItems(forOrderWithId: order.id)
    }
    
    
    var orderItemsToPick: [OrderItem] { orderItems
        .filter { !pickedItems.contains($0.id) }
        .sorted { $0.location < $1.location }
    }
    var orderItemsToVerify: [OrderItem] { orderItems
        .filter { pickedItems.contains($0.id) && !verifiedItems.contains($0.id) }
        .sorted { a, b in a.condition == "N" }
    }
}
