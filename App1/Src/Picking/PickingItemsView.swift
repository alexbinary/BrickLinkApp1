
import SwiftUI



struct PickingItemsView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderIds: Set<OrderId>
    let orderItems: [OrderItem]
    
    
    var body: some View {
                    
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􁊇 Items")
            
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
                        ForEach(nextItemsToPick) { item in
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
                    TableColumn("Condition", value: \.condition)
                    TableColumn("Color", value: \.color)
                    TableColumn("Ref", value: \.ref)
                    TableColumn("Name", value: \.name)
                    TableColumn("Comment", value: \.comment)
                    TableColumn("Quantity", value: \.quantity)
                    
                } rows: {
                    
                    Section("Next") {
                        ForEach(nextItemsToVerify) { item in
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
                    TableColumn("Condition", value: \.condition)
                    TableColumn("Color", value: \.color)
                    TableColumn("Ref", value: \.ref)
                    TableColumn("Name", value: \.name)
                    TableColumn("Comment", value: \.comment)
                    TableColumn("Quantity", value: \.quantity)
                }
                .frame(minHeight: 400)
            }
        }
    }
    
    
    var pickedItems: [InventoryId] {
        
        var items: [InventoryId] = []
        
        for orderId in selectedOrderIds {
            items.append(contentsOf: appController.pickedItems(forOrderWithId: orderId))
        }
        return items
    }
    
    var verifiedItems: [InventoryId] {
        
        var items: [InventoryId] = []
        
        for orderId in selectedOrderIds {
            items.append(contentsOf: appController.verifiedItems(forOrderWithId: orderId))
        }
        return items
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
        
        if !nextItemsToPick.isEmpty {
        
            for item in nextItemsToPick {
                appController.pickItem(forOrderWithId: item.orderId, item: item.id)
            }
        }
    }
    
    
    func nextVerify() {
        
        if !nextItemsToVerify.isEmpty {
            
            for item in nextItemsToVerify {
                appController.verifyItem(forOrderWithId: item.orderId, item: item.id)
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
