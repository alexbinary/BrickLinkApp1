
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
                            ForEach(orderItemsToPick) { itemView($0, buttons: [.pick]) }
                        }
                    }
                    .padding()
                    .tabItem {
                        Text("􀈥 Pick")
                    }
                }
                
                if !pickedItems.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(pickedItems.reversed(), id: \.self) { item in
                                itemView(orderItems.first { $0.id == item }!, buttons: [.unpick])
                            }
                        }
                    }
                    .padding()
                    .tabItem {
                        Text("􀐫 Picked")
                    }
                }
            
                if !orderItemsToVerify.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(orderItemsToVerify) { itemView($0, buttons: [.verify]) }
                        }
                    }
                    .padding()
                    .tabItem {
                        Text("􀁢 Verify")
                    }
                }
                
                if !verifiedItems.isEmpty {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(verifiedItems.reversed(), id: \.self) { item in
                                itemView(orderItems.first { $0.id == item }!, buttons: [.unverify])
                            }
                        }
                    }
                    .padding()
                    .tabItem {
                        Text("􀐫 Verified")
                    }
                }
            }
        }
        .padding()
        .onChange(of: order, initial: true) {
            Task {
                await parallel([
                    { await loadOrder() },
                    { await loadOrderItems() },
                ])
            }
        }
        .onAppear {
            Task {
                await app.reloadInventories()
            }
        }
    }
    
    
    @ViewBuilder
    func headerView(_ primaryText: String?, secondaryText: String = "") -> some View {
        
        HStack(spacing: 24) {
            if let text = primaryText {
                Text(text).font(.title3)
            }
            Text(secondaryText).foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.windowBackgroundColor.opacity(0.90))
    }
    
    
    @ViewBuilder
    func itemView(_ item: OrderItem, buttons: [ButtonEnum]) -> some View {
        
        HStack(spacing: 48) {
                
            Grid(verticalSpacing: 0) {
                
                GridRow(alignment: .top) {
                    
                    AsyncImage(url: app.url(for: item))
                        .frame(minHeight: 70, maxHeight: 70, alignment: .top)
                        .frame(minWidth: 90, maxWidth: 90, alignment: .top)
                    
                    VStack(alignment: .leading) {
                        Text(item.ref).font(.caption).foregroundStyle(.secondary)
                        Text(item.name.htmlUnescape()).lineLimit(nil).font(.title3).frame(width: 300, alignment: .leading)
                        if !item.comment.isEmpty {
                            Text(item.comment.htmlUnescape())
                        }
                    }
                }
                
                GridRow {
                
                    Text(item.condition == "U" ? "USED" : "NEW").font(.title3).gridColumnAlignment(.center)
                    HStack {
                        app.color(for: item).frame(width: 18, height: 18)
                        Text(app.colorName(for: item))
                    }.gridColumnAlignment(.leading)
                }
            }
            
            let itemIsPicked = app.pickedItems(forOrderWithId: item.orderId).contains(item.id)
            
            Grid(alignment: .leading) {
                
                GridRow {
                    Text("Location").font(.caption).foregroundStyle(.secondary)
                    Text("Quantity").font(.caption).foregroundStyle(.secondary)
                        .gridColumnAlignment(.center)
                }
                
                GridRow(alignment: .lastTextBaseline) {
                    Text(item.location).font(.title2).frame(width: 80, alignment: .leading)
                    Text(item.quantity).font(.title2)
                    HStack(spacing: 0) {
                        let stock = app.inStockQuantity(for: item)
                        let qty = Int(item.quantity)!
                        let (before, after) = {
                            if !itemIsPicked {
                                return (stock, stock - qty)
                            } else {
                                return (stock + qty, stock)
                            }
                        }()
                        Text("(\(before) 􁉂 ")
                        Text(after, format: .number)
                            .foregroundStyle(after == 0 ? .red.opacity(0.7) : .secondary)
                        Text(")")
                    }
                    .foregroundStyle(.secondary)
                
                }
            }
            
            Spacer()
            
            VStack (alignment: .leading) {
                
                ForEach(buttons, id: \.self) { button in
                    switch button {
                    case .pick:
                        Button {
                            app.pickItem(forOrderWithId: item.orderId, item: item.id)
                        } label: {
                            Text("Pick")
                        }
                    case .unpick:
                        Button {
                            app.unpickItem(forOrderWithId: item.orderId, item: item.id)
                        } label: {
                            Text("Unpick")
                        }
                    case .verify:
                        Button {
                            app.verifyItem(forOrderWithId: item.orderId, item: item.id)
                        } label: {
                            Text("Verify")
                        }
                    case .unverify:
                        Button {
                            app.unverifyItem(forOrderWithId: item.orderId, item: item.id)
                        } label: {
                            Text("Unverify")
                        }
                    }
                }
            }
        }
        .padding()
        .roundedContainer(
            backgroundColor: .secondarySystemFill,
            borderColor: .tertiarySystemFill
        )
    }
    
    
    func loadOrder() async {
        
        await app.loadOrderDetailsIfMissing(forOrderWithId: order.id)
    }
    
    
    func loadOrderItems() async {
        
        await app.loadOrderItemsIfMissing(forOrderWithId: order.id)
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
 

enum ButtonEnum {
    
    case pick
    case unpick
    case verify
    case unverify
}
