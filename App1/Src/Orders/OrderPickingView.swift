
import SwiftUI



struct OrderPickingView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderDetails.ID
    
    
    var body: some View {
            
        VStack(alignment: .leading) {
            
            let total = appController.orderItems(forOrderWithId: orderId).count
            let picked = appController.pickedItems(forOrderWithId: orderId).count
            let verified = appController.verifiedItems(forOrderWithId: orderId).count
            
            let allPicked = picked == total
            let allVerified = verified == total
            
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
            
            ScrollView {
                
                LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                    
                    if !allPicked {
                        
                        section(header: "Pick", footer: "All items picked 􀁢", items: orderItemsToPick, hideIfEmpty: true)
                    }
                    
                    if !allVerified {
                        
                        section(header: "Verify", footer: "All items verified 􀁢", items: orderItemsToVerify, hideIfEmpty: allPicked)
                    }
                    
                    section(header: "Picked and verified", items: orderItemsPickedAndVerified, hideIfEmpty: true)
                }
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
    func section(header: String?, footer: String? = nil, items: [OrderItem], hideIfEmpty: Bool) -> some View {
        
        if !items.isEmpty || !hideIfEmpty {
            
            Section {
                
                ForEach(items) { item in
                    
                    itemView(item)
                }
                
            } header: {
                
                headerFooterView(header, secondaryText: "\(items.count) items")
                
            } footer: {
                
                headerFooterView(footer).foregroundStyle(.secondary)
            }
        }
    }
    
    
    @ViewBuilder
    func headerFooterView(_ primaryText: String?, secondaryText: String = "") -> some View {
        
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
}
 
