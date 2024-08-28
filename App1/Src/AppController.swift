
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
    
    
    func getOrderItems(orderId: String) async -> [OrderItem] {
        
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
                    comment: item.description,
                    quantity: "\(item.quantity)",
                    quantityLeft: ""
                )
            }
        }
        
        return []
    }
    
    
    func updateOrderStatus(orderId: String, status: String) async {
        
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
    
    
    func sendDriveThru(orderId: String) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/drive_thru?mail_me=true")!)
        request.httpMethod = "POST"
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
    }
    
    
    func shippingCost(forOrderWithId id: String) -> Float {
        
        return dataStore.shippingCostsByOrderId[id] ?? 0
    }
    
    
    func updateShippingCost(forOrderWithId id: String, cost: Float) {
        
        var shippingCostsByOrderId = dataStore.shippingCostsByOrderId
        
        shippingCostsByOrderId[id] = cost
        
        try! dataStore.setShippingCostsByOrderId(shippingCostsByOrderId)
        try! dataStore.save()
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
