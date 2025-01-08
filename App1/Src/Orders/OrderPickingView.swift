
import SwiftUI



struct OrderPickingView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderDetails.ID
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                
                Button {
                    for item in orderItems {
                        appController.pickItem(forOrderWithId: item.orderId, item: item.id)
                    }
                } label: {
                    Text("Pick all")
                }
                
                Button {
                    for item in orderItems {
                        appController.unpickItem(forOrderWithId: item.orderId, item: item.id)
                    }
                } label: {
                    Text("Unpick all")
                }
                
                Button {
                    for item in orderItems {
                        appController.verifyItem(forOrderWithId: item.orderId, item: item.id)
                    }
                } label: {
                    Text("Verify all")
                }
                
                Button {
                    for item in orderItems {
                        appController.unverifyItem(forOrderWithId: item.orderId, item: item.id)
                    }
                } label: {
                    Text("Unverify all")
                }
            }
            
            HStack {
                
                Button {
                    next()
                } label: {
                    Text("Pick or verify next")
                }
                
                Button {
                    nextPick()
                } label: {
                    Text("Pick next")
                }
                
                Button {
                    nextVerify()
                } label: {
                    Text("Verify next")
                }
            }
            
            ScrollView {
                
                LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                    
                    section(header: "Pick next", items: nextItemsToPick)
                    section(header: "Pick after", items: orderItemsToPick.filter { pick in !nextItemsToPick.contains { next in next.id == pick.id } })
               
                    section(header: "Verify next", items: nextItemsToVerify)
                    section(header: "Verify after", items: orderItemsToVerify.filter { pick in !nextItemsToVerify.contains { next in next.id == pick.id } })
               
                    section(header: "Picked and verified", items: orderItemsPickedAndVerified)
                }
            }
        }
        .padding()
        .task {
            await parallel([
                { await loadOrder() },
                { await loadOrderItems() },
            ])
        }
        .onChange(of: orderId) { oldValue, newValue in
            Task {
                await parallel([
                    { await loadOrder() },
                    { await loadOrderItems() },
                ])
            }
        }
    }
    
    
    @ViewBuilder
    func section(header: String, items: [OrderItem]) -> some View {
        
        if items.count > 0 {
            
            Section {
                
                ForEach(items) { item in
                    
                    itemView(item)
                }
                
                Color.clear.frame(width: 0, height: 24)
                
            } header: {
                
                headerView(header, secondaryText: "\(items.count) items")
            }
        }
    }
    
    
    @ViewBuilder
    func headerView(_ primaryText: String, secondaryText: String = "") -> some View {
        
        HStack(spacing: 24) {
            Text(primaryText).font(.title3)
            Text(secondaryText).foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.90))
    }
    
    
    @ViewBuilder
    func itemView(_ item: OrderItem) -> some View {
        
        HStack(spacing: 24) {
            
            HStack(alignment: .top, spacing: 12) {
                
                Grid(verticalSpacing: 0) {
                    
                    GridRow(alignment: .top) {
                        
                        AsyncImage(url: appController.imageUrl(for: item))
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
                            appController.color(for: item).frame(width: 18, height: 18)
                            Text(appController.colorName(for: item))
                        }.gridColumnAlignment(.leading)
                    }
                }
            }
            
            Grid(alignment: .leading) {
                
                GridRow {
                    Text("Location").font(.caption).foregroundStyle(.secondary)
                    Text("Pick").font(.caption).foregroundStyle(.secondary)
                    Text("Left").font(.caption).foregroundStyle(.secondary)
                }
                
                GridRow(alignment: .bottom) {
                    Text(item.location).font(.title2).frame(width: 80, alignment: .leading)
                    Text(item.quantity).font(.title2).gridColumnAlignment(.center)
                    Text(item.quantityLeft).gridColumnAlignment(.center)
                }
            }
            
            VStack (alignment: .leading) {
                
                let picked = appController.pickedItems(forOrderWithId: item.orderId).contains(item.id)
                let verified = appController.verifiedItems(forOrderWithId: item.orderId).contains(item.id)
                
                if !picked {
                    Button {
                        appController.pickItem(forOrderWithId: item.orderId, item: item.id)
                    } label: {
                        Text("Pick")
                    }
                }
                
                if picked && !verified {
                    
                    Button {
                        appController.unpickItem(forOrderWithId: item.orderId, item: item.id)
                    } label: {
                        Text("Unpick")
                    }
                    Button {
                        appController.verifyItem(forOrderWithId: item.orderId, item: item.id)
                    } label: {
                        Text("Verify")
                    }
                }
                
                if picked && verified {
                    
                    Button {
                        appController.unpickItem(forOrderWithId: item.orderId, item: item.id)
                        appController.unverifyItem(forOrderWithId: item.orderId, item: item.id)
                    } label: {
                        Text("Unpick")
                    }
                    Button {
                        appController.unverifyItem(forOrderWithId: item.orderId, item: item.id)
                    } label: {
                        Text("Unverify")
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .secondarySystemFill))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .tertiarySystemFill))
        )
    }
    
    
    func loadOrder() async {
        
        await appController.loadOrderDetailsIfMissing(forOrderWithId: orderId)
    }
    
    
    func loadOrderItems() async {
        
        await appController.loadOrderItemsIfMissing(forOrderWithId: orderId)
    }
    
    
    var orderItems: [OrderItem] {
        appController.orderItems(forOrderWithId: orderId)
    }
    
    var pickedItems: [OrderItem.ID] {
        appController.pickedItems(forOrderWithId: orderId)
    }
    
    var verifiedItems: [OrderItem.ID] {
        appController.verifiedItems(forOrderWithId: orderId)
    }
    
    
    var orderItemsToPick: [OrderItem] { orderItems
        .filter { !pickedItems.contains($0.id) }
        .sorted { $0.location < $1.location }
    }
    var orderItemsToVerify: [OrderItem] { orderItems
        .filter { pickedItems.contains($0.id) && !verifiedItems.contains($0.id) }
        .sorted { a, b in a.condition == "N" }
    }
    var orderItemsPickedAndVerified: [OrderItem] { orderItems
        .filter { pickedItems.contains($0.id) && verifiedItems.contains($0.id) }
        .sorted { $0.location < $1.location }
    }
    
    
    var nextItemsToPick: [OrderItem] {
        
        var nextItems: [OrderItem] = []
        
        var orderItemsToPick = orderItemsToPick
        
        if !orderItemsToPick.isEmpty {
            nextItems.append(orderItemsToPick.removeFirst())
            while !orderItemsToPick.isEmpty && orderItemsToPick.first!.location == nextItems.last!.location {
                nextItems.append(orderItemsToPick.removeFirst())
            }
        }
        
        return nextItems
    }
    
    
    var nextItemsToVerify: [OrderItem] {
        
        var orderItemsToVerify = orderItemsToVerify
        
        var nextItems: [OrderItem] = []
        
        if !orderItemsToVerify.isEmpty {
            nextItems.append(orderItemsToVerify.removeFirst())
        }
        
        return nextItems
    }
    
    
    var nextItems: [OrderItem] {
        
        if !nextItemsToPick.isEmpty {
            return nextItemsToPick
        }
        
        if !nextItemsToVerify.isEmpty {
            return nextItemsToVerify
        }
        
        return []
    }
    
    
    func nextPick() {
        
        if let item = nextItemsToPick.first {
            
            appController.pickItem(forOrderWithId: item.orderId, item: item.id)
        }
    }
    
    
    func nextVerify() {
        
        if let item = nextItemsToVerify.first {
            
            appController.verifyItem(forOrderWithId: item.orderId, item: item.id)
        }
    }
    
    
    func next() {
        
        if !nextItemsToPick.isEmpty {
        
            nextPick()
            
        } else if !nextItemsToVerify.isEmpty {
            
            nextVerify()
        }
    }
}
 
