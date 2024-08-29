
import SwiftUI


struct PickingDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderId: Order.ID?
    
    @State var orderItems: [OrderItem] = []
    
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                if selectedOrderId == nil {
                    
                    Text("select an order")
                    
                } else if orderItems.isEmpty {
                    
                    Text("loading order...")
                    
                } else if let orderId = selectedOrderId {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􁊇 Items")
                        
                        HStack {
                            
                            Button {
                                for item in orderItems {
                                    appController.pickItem(forOrderWithId: orderId, item: item.id)
                                }
                            } label: {
                                Text("Pick all")
                            }
                            
                            Button {
                                for item in orderItems {
                                    appController.unpickItem(forOrderWithId: orderId, item: item.id)
                                }
                            } label: {
                                Text("Unpick all")
                            }
                            
                            Button {
                                for item in orderItems {
                                    appController.verifyItem(forOrderWithId: orderId, item: item.id)
                                }
                            } label: {
                                Text("Verify all")
                            }
                            
                            Button {
                                for item in orderItems {
                                    appController.unverifyItem(forOrderWithId: orderId, item: item.id)
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
                        }
                        
                        if !orderItemsToPick.isEmpty {
                            
                            Text("Pick").font(.title2)
                            
                            Button {
                                nextPick()
                            } label: {
                                Text("Pick next")
                            }
                            
                            Table(of: OrderItem.self) {
                                
                                TableColumn("Status") { item in
                                    
                                    let picked = appController.pickedItems(forOrderWithId: orderId).contains(item.id)
                                    let verified = appController.verifiedItems(forOrderWithId: orderId).contains(item.id)
                                    
                                    if !picked {
                                        Button {
                                            appController.pickItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Pick")
                                        }
                                    }
                                    
                                    if picked && !verified {
                                        
                                        Button {
                                            appController.unpickItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Unpick")
                                        }
                                        Button {
                                            appController.verifyItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Verify")
                                        }
                                    }
                                    
                                    if picked && verified {
                                        
                                        Button {
                                            appController.unpickItem(forOrderWithId: orderId, item: item.id)
                                            appController.unverifyItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Unpick")
                                        }
                                        Button {
                                            appController.unverifyItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Unverify")
                                        }
                                    }
                                }
                                TableColumn("Condition", value: \.condition)
                                TableColumn("Color", value: \.color)
                                TableColumn("Ref", value: \.ref)
                                TableColumn("Name", value: \.name)
                                TableColumn("Comment", value: \.comment)
                                TableColumn("Location", value: \.location)
                                TableColumn("Quantity", value: \.quantity)
                                TableColumn("Left", value: \.quantityLeft)
                                
                            } rows: {
                                
                                Section("Next") {
                                    ForEach(orderItemsToPick.filter { pick in nextItemsToPick.contains { next in next.id == pick.id } }) { item in
                                        TableRow(item)
                                    }
                                }
                                Section("Coming") {
                                    ForEach(orderItemsToPick.filter { pick in !nextItemsToPick.contains { next in next.id == pick.id } }) { item in
                                        TableRow(item)
                                    }
                                }
                            }
                            .frame(minHeight: 400)
                        }
                        
                        if !orderItemsToVerify.isEmpty {
                            
                            Text("Verify").font(.title2)
                            
                            Button {
                                nextVerify()
                            } label: {
                                Text("Verify next")
                            }
                            
                            Table(of: OrderItem.self) {
                                
                                TableColumn("Status") { item in
                                    
                                    let picked = appController.pickedItems(forOrderWithId: orderId).contains(item.id)
                                    let verified = appController.verifiedItems(forOrderWithId: orderId).contains(item.id)
                                    
                                    if !picked {
                                        Button {
                                            appController.pickItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Pick")
                                        }
                                    }
                                    
                                    if picked && !verified {
                                        
                                        Button {
                                            appController.unpickItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Unpick")
                                        }
                                        Button {
                                            appController.verifyItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Verify")
                                        }
                                    }
                                    
                                    if picked && verified {
                                        
                                        Button {
                                            appController.unpickItem(forOrderWithId: orderId, item: item.id)
                                            appController.unverifyItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Unpick")
                                        }
                                        Button {
                                            appController.unverifyItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Unverify")
                                        }
                                    }
                                }
                                TableColumn("Condition", value: \.condition)
                                TableColumn("Color", value: \.color)
                                TableColumn("Ref", value: \.ref)
                                TableColumn("Name", value: \.name)
                                TableColumn("Comment", value: \.comment)
                                TableColumn("Quantity", value: \.quantity)
                                
                            } rows: {
                                
                                Section("Next") {
                                    ForEach(orderItemsToVerify.filter { pick in nextItemsToVerify.contains { next in next.id == pick.id } }) { item in
                                        TableRow(item)
                                    }
                                }
                                Section("Coming") {
                                    ForEach(orderItemsToVerify.filter { pick in !nextItemsToVerify.contains { next in next.id == pick.id } }) { item in
                                        TableRow(item)
                                    }
                                }
                            }
                            .frame(minHeight: 400)
                        }
                        
                        if !orderItemsPickedAndVerified.isEmpty {
                            
                            Text("Picked and verified").font(.title2)
                            
                            Table(orderItemsPickedAndVerified) {
                                
                                TableColumn("Status") { item in
                                    
                                    let picked = appController.pickedItems(forOrderWithId: orderId).contains(item.id)
                                    let verified = appController.verifiedItems(forOrderWithId: orderId).contains(item.id)
                                    
                                    if !picked {
                                        Button {
                                            appController.pickItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Pick")
                                        }
                                    }
                                    
                                    if picked && !verified {
                                        
                                        Button {
                                            appController.unpickItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Unpick")
                                        }
                                        Button {
                                            appController.verifyItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Verify")
                                        }
                                    }
                                    
                                    if picked && verified {
                                        
                                        Button {
                                            appController.unpickItem(forOrderWithId: orderId, item: item.id)
                                            appController.unverifyItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Unpick")
                                        }
                                        Button {
                                            appController.unverifyItem(forOrderWithId: orderId, item: item.id)
                                        } label: {
                                            Text("Unverify")
                                        }
                                    }
                                }
                                TableColumn("Condition", value: \.condition)
                                TableColumn("Color", value: \.color)
                                TableColumn("Ref", value: \.ref)
                                TableColumn("Name", value: \.name)
                                TableColumn("Comment", value: \.comment)
                                TableColumn("Quantity", value: \.quantity)
                            }
                            .frame(minHeight: 400)
                        }
                        
                        Divider()
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .task {
                await loadOrderItems()
            }
            .onChange(of: selectedOrderId) { oldValue, newValue in
                Task {
                    await loadOrderItems()
                }
            }
        }
    }
    
    
    func loadOrderItems() async {
        
        guard let orderId = selectedOrderId else { return }
        
        self.orderItems.removeAll()
        self.orderItems = await appController.getOrderItems(orderId: orderId)
    }
    
    
    var pickedItems: [InventoryId] {
        guard let orderId = selectedOrderId else { return [] }
        return appController.pickedItems(forOrderWithId: orderId)
    }
    var verifiedItems: [InventoryId] {
        guard let orderId = selectedOrderId else { return [] }
        return appController.verifiedItems(forOrderWithId: orderId)
    }
    
    
    var orderItemsToPick: [OrderItem] { orderItems
        .filter { !pickedItems.contains($0.id) }
        .sorted { $0.location < $1.location }
    }
    var orderItemsToVerify: [OrderItem] { orderItems
        .filter { pickedItems.contains($0.id) && !verifiedItems.contains($0.id) }
        .sorted { $0.location < $1.location }
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
            while !orderItemsToVerify.isEmpty && orderItemsToVerify.first!.location == nextItems.last!.location {
                nextItems.append(orderItemsToVerify.removeFirst())
            }
            
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
        
        guard let orderId = selectedOrderId else { return }
        
        if !nextItemsToPick.isEmpty {
        
            for item in nextItemsToPick {
                appController.pickItem(forOrderWithId: orderId, item: item.id)
            }
        }
    }
    
    
    func nextVerify() {
        
        guard let orderId = selectedOrderId else { return }
        
        if !nextItemsToVerify.isEmpty {
            
            for item in nextItemsToVerify {
                appController.verifyItem(forOrderWithId: orderId, item: item.id)
            }
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
