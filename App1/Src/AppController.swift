
import SwiftUI


class AppController: ObservableObject {
    
    
    private let dataStore: DataStore
    private let blCredentials: BrickLinkAPICredentials
    
    
    init(
        dataStore: DataStore,
        blCredentials: BrickLinkAPICredentials
    ) {
        
        self.dataStore = dataStore
        self.blCredentials = blCredentials
    }
    
    
    @Published var orders: [Order] = []
    
    
    func reloadOrders() async {
        
        DispatchQueue.main.sync {
            orders = []
        }
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkOrder]> = data.decode()
        if let blOrders = decoded.data {
            
            DispatchQueue.main.sync {
                
                self.orders = blOrders
                    .map { Order(fromBlOrder: $0) }
                    .sorted { $0.date > $1.date }
            }
        }
    }
    
    
    func getOrder(orderId: String) async -> Order? {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<BrickLinkOrder> = data.decode()
        if let blOrder = decoded.data {
            
            return Order(fromBlOrder: blOrder)
        }
        
        return nil
    }
    
    
    func getOrderItems(orderId: OrderId) async -> [OrderItem] {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/items")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        
        let decoded: BrickLinkAPIResponse<[[BrickLinkOrderItem]]> = data.decode()
        if let batches = decoded.data, let items = batches.first {
            
            return items.map { item in
                
                OrderItem(
                    id: "\(item.inventoryId)",
                    condition: item.newOrUsed,
                    color: "\(item.colorId)",
                    ref: item.item.no,
                    name: item.item.name,
                    location: item.remarks,
                    comment: item.description ?? "",
                    quantity: "\(item.quantity)",
                    quantityLeft: ""
                )
            }
        }
        
        return []
    }
    
    
    func updateOrderStatus(orderId: OrderId, status: String) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/status")!)
        request.httpMethod = "PUT"
        request.httpBody = """
            {
                "field" : "status",
                "value" : "\(status)"
            }
            """.data(using: .utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        await reloadOrders()
    }
    
    
    func updateTrackingNo(forOrderWithId orderId: OrderId, trackingNo: String) async {
        
        print("update tracking no \(trackingNo) for order \(orderId)")
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)")!)
        request.httpMethod = "PUT"
        request.httpBody = """
            {
                "shipping": {
                    "tracking_no": "\(trackingNo)"
                }
            }
            """.data(using: .utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
    }


    func sendDriveThru(orderId: OrderId) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/drive_thru?mail_me=true")!)
        request.httpMethod = "POST"
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
    }
    
    
    func shippingCost(forOrderWithId orderId: OrderId) -> Float {
        
        return dataStore.shippingCostsByOrderId[orderId] ?? 0
    }
    
    
    func pickedItems(forOrderWithId orderId: OrderId) -> [InventoryId] {
        
        return dataStore.pickedItemsByOrderId[orderId] ?? []
    }
    
    
    func verifiedItems(forOrderWithId orderId: OrderId) -> [InventoryId] {
        
        return dataStore.verifiedItemsByOrderId[orderId] ?? []
    }
    
    
    func updateShippingCost(forOrderWithId orderId: OrderId, cost: Float) {
        
        var shippingCostsByOrderId = dataStore.shippingCostsByOrderId
        
        shippingCostsByOrderId[orderId] = cost
        
        try! dataStore.setShippingCostsByOrderId(shippingCostsByOrderId)
        try! dataStore.save()
    }
    
    
    func pickItem(forOrderWithId orderId: OrderId, item itemId: InventoryId) {
        
        var pickedItemsByOrderId = dataStore.pickedItemsByOrderId
        var pickedItemsForOrder = dataStore.pickedItemsByOrderId[orderId] ?? [InventoryId]()
        
        guard !pickedItemsForOrder.contains(itemId) else { return }
            
        pickedItemsForOrder.append(itemId)
        pickedItemsByOrderId[orderId] = pickedItemsForOrder
        
        try! dataStore.setPickedItemsByOrderId(pickedItemsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    func unpickItem(forOrderWithId orderId: OrderId, item itemId: InventoryId) {
        
        var pickedItemsByOrderId = dataStore.pickedItemsByOrderId
        var pickedItemsForOrder = dataStore.pickedItemsByOrderId[orderId] ?? [InventoryId]()
        
        pickedItemsForOrder.removeAll { $0 == itemId }
        pickedItemsByOrderId[orderId] = pickedItemsForOrder
        
        if pickedItemsByOrderId[orderId]!.isEmpty {
            pickedItemsByOrderId.removeValue(forKey: orderId)
        }
        
        try! dataStore.setPickedItemsByOrderId(pickedItemsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    func verifyItem(forOrderWithId orderId: OrderId, item itemId: InventoryId) {
        
        var verifiedItemsByOrderId = dataStore.verifiedItemsByOrderId
        var verifiedItemsForOrder = dataStore.verifiedItemsByOrderId[orderId] ?? [InventoryId]()
        
        guard !verifiedItemsForOrder.contains(itemId) else { return }
            
        verifiedItemsForOrder.append(itemId)
        verifiedItemsByOrderId[orderId] = verifiedItemsForOrder
        
        try! dataStore.setVerifiedItemsByOrderId(verifiedItemsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    func unverifyItem(forOrderWithId orderId: OrderId, item itemId: InventoryId) {
        
        var verifiedItemsByOrderId = dataStore.verifiedItemsByOrderId
        var verifiedItemsForOrder = dataStore.verifiedItemsByOrderId[orderId] ?? [InventoryId]()
        
        verifiedItemsForOrder.removeAll { $0 == itemId }
        verifiedItemsByOrderId[orderId] = verifiedItemsForOrder
        
        if verifiedItemsByOrderId[orderId]!.isEmpty {
            verifiedItemsByOrderId.removeValue(forKey: orderId)
        }
        
        try! dataStore.setVerifiedItemsByOrderId(verifiedItemsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
}


extension Order {
    
    
    init(fromBlOrder blOrder: BrickLinkOrder) {
        
        self.id = "\(blOrder.orderId)"
        self.date = blOrder.dateOrdered
        self.buyer = blOrder.buyerName
        self.items = blOrder.totalCount
        self.lots = blOrder.uniqueCount
        self.grandTotal = blOrder.cost.grandTotal.floatValue
        self.status = blOrder.status
        self.driveThruSent = blOrder.driveThruSent ?? false
        self.trackingNo = blOrder.shipping?.trackingNo
        self.totalWeight = blOrder.totalWeight?.floatValue
    }
}


extension Data {
    
    
    func decode<T>() -> T where T: Decodable {
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        decoder.dateDecodingStrategy = .custom({ (decoder) in
            let stringValue = try! decoder.singleValueContainer().decode(String.self)
            return dateFormatter.date(from: stringValue)!
        })
        
        let decoded = try! decoder.decode(T.self, from: self)
        
        return decoded
    }
}
