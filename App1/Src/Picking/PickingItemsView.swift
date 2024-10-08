
import SwiftUI
import HTMLEntities



struct PickingItemsView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderIds: Set<OrderSummary.ID>
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
                    TableColumn("Image") { item in
                        AsyncImage(url: appController.imageUrl(for: item))
                            .frame(minHeight: 60)
                    }
                    TableColumn("Color") { item in
                        HStack {
                            appController.color(for: item).frame(width: 18, height: 18)
                            Text(appController.colorName(for: item))
                        }
                    }
                    TableColumn("Condition", value: \.condition)
                    TableColumn("Location", value: \.location)
                    TableColumn("Quantity", value: \.quantity)
                    TableColumn("Left", value: \.quantityLeft)
                    TableColumn("Name") { item in
                        Text(item.name.htmlUnescape()).lineLimit(nil)
                    }
                    TableColumn("Ref", value: \.ref)
                    TableColumn("Comment", value: \.comment)
                    
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
                    TableColumn("Image") { item in
                        AsyncImage(url: appController.imageUrl(for: item))
                            .frame(minHeight: 60)
                    }
                    TableColumn("Color") { item in
                        HStack {
                            appController.color(for: item).frame(width: 18, height: 18)
                            Text(appController.colorName(for: item))
                        }
                    }
                    TableColumn("Quantity", value: \.quantity)
                    TableColumn("Name") { item in
                        Text(item.name.htmlUnescape()).lineLimit(nil)
                    }
                    TableColumn("Location", value: \.location)
                    TableColumn("Ref", value: \.ref)
                    TableColumn("Comment", value: \.comment)
                    
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
                    TableColumn("Image") { item in
                        AsyncImage(url: appController.imageUrl(for: item))
                            .frame(minHeight: 60)
                    }
                    TableColumn("Condition", value: \.condition)
                    TableColumn("Color") { item in
                        HStack {
                            appController.color(for: item).frame(width: 18, height: 18)
                            Text(appController.colorName(for: item))
                        }
                    }
                    TableColumn("Name") { item in
                        Text(item.name.htmlUnescape()).lineLimit(nil)
                    }
                    TableColumn("Ref", value: \.ref)
                    TableColumn("Comment", value: \.comment)
                    TableColumn("Quantity", value: \.quantity)
                }
                .frame(minHeight: 400)
            }
        }
    }
    
    
    var pickedItems: [OrderItem.ID] {
        
        var items: [OrderItem.ID] = []
        
        for orderId in selectedOrderIds {
            items.append(contentsOf: appController.pickedItems(forOrderWithId: orderId))
        }
        return items
    }
    
    var verifiedItems: [OrderItem.ID] {
        
        var items: [OrderItem.ID] = []
        
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
