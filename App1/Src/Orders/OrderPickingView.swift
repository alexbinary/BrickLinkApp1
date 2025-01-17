
import SwiftUI



struct OrderPickingView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderDetails.ID
    
    
    var body: some View {
            
        ScrollView {
            
            let total = appController.orderItems(forOrderWithId: orderId).count
            let picked = appController.pickedItems(forOrderWithId: orderId).count
            let verified = appController.verifiedItems(forOrderWithId: orderId).count
            
            let allPicked = picked == total
            let allVerified = verified == total
            
            LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                
                Group {
                    if !allPicked {
                        
                        let percent = floor(Double(picked)/Double(total)*100)
                        Text(String(format: "Picking %3.0f%% complete", percent))
                        
                    } else if !allVerified {
                        
                        let percent = floor(Double(verified)/Double(total)*100)
                        Text(String(format: "All items picked, verified %3.0f%%", percent))
                        
                    } else {
                        
                        Text("All items picked and verified 􀁣")
                    }
                }
                .font(.title)
                .padding()
                .padding(.vertical, 12)
                
                if !allPicked {
                    
                    section(header: "Pick next", items: nextItemsToPick, hideIfEmpty: true)
                    section(header: "Pick", items: orderItemsToPick.filter { pick in !nextItemsToPick.contains { next in next.id == pick.id } }, hideIfEmpty: true)
                    
                    Text("All items picked 􀁢")
                        .foregroundStyle(.secondary)
                        .font(.title)
                        .padding()
                        .padding(.vertical, 12)
                }
                
                if !allVerified {
                    
                    section(header: "Verify next", items: nextItemsToVerify, hideIfEmpty: true)
                    section(header: "Verify", items: orderItemsToVerify.filter { pick in !nextItemsToVerify.contains { next in next.id == pick.id } }, hideIfEmpty: allPicked)
                    
                    Text("All items verified 􀁢")
                        .foregroundStyle(.secondary)
                        .font(.title)
                        .padding()
                        .padding(.vertical, 12)
                }
                
                section(header: "Picked and verified", items: orderItemsPickedAndVerified, hideIfEmpty: true)
            }
        }
        .padding()
        .onChange(of: orderId, initial: true) {
            Task {
                await parallel([
                    { await loadOrder() },
                    { await loadOrderItems() },
                ])
            }
        }
    }
    
    
    @ViewBuilder
    func section(header: String?, items: [OrderItem], hideIfEmpty: Bool) -> some View {
        
        if !items.isEmpty || !hideIfEmpty {
            
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
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.90))
    }
    
    
    @ViewBuilder
    func itemView(_ item: OrderItem) -> some View {
        
        HStack(spacing: 48) {
                
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
                        let stock = appController.inStockQuantity(for: item)
                        let left = stock - Int(item.quantity)!
                        Text("(\(stock) 􁉂 ")
                        Text(left, format: .number)
                            .foregroundStyle(left == 0 ? .red.opacity(0.7) : .secondary)
                        Text(")")
                    }
                    .foregroundStyle(.secondary)
                
                }
            }
            
            Spacer()
            
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
 
