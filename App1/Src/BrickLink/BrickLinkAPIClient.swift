
import Foundation



struct BrickLinkAPIClient {
    
    
    
    // MARK: - Infra
    
    
    private static let credentials = Secrets.brickLinkAPICredentials
    
    
    enum Method: String {
        
        case PUT="PUT"
        case POST="POST"
    }
    
    
    @discardableResult
    private static func send(withMethod method: Method? = nil, to url: URL, body: ()->String? = {nil}) async throws -> (Data, URLResponse) {
        
        var request = URLRequest(url: url)
        request.addAuthentication(using: credentials)
        
        if let method = method {
            request.httpMethod = method.rawValue
        }
        if let body = body() {
            request.httpBody = body.data(using: .utf8)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
        }
        
        Debug.printRequest(request)
        
        let (data, response) = try! await URLSession(configuration: .default).data(for: request)
        
        Debug.printResponse(data, response)
        
        return (data, response)
    }
    
    
    private static let decoder = {
        
        var decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom({ (decoder) in
            
            let stringValue = try! decoder.singleValueContainer().decode(String.self)
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
            
            return dateFormatter.date(from: stringValue)!
        })
        return decoder
    }()
    
    
    private static func fetchAndDecodeData<T: Decodable>(from url: URL, withMethod method: Method? = nil, body: ()->String? = {nil}) async throws -> T {
        
        let (data, _) = try! await send(withMethod: method, to: url, body: body)
        
        let decoded = try! decoder.decode(BrickLinkAPIResponse<T>.self, from: data)
        return decoded.data!
    }
    
    
    
    // MARK: - Catalog
        
        
    static func fetchColors() async -> [BrickLinkColor] {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/colors")!)
    }
    
    
    static func fetchCatalogEntry(forItemType type: BrickLinkItemType, ref: String) async -> BrickLinkCatalogItem? {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/items/\(type.rawValue)/\(ref)")!)
    }
    
    
    
    // MARK: - Orders
    
    
    static func fetchOrderSummaries() async -> [BrickLinkOrder] {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/orders")!)
    }
    
    
    static func fetchDetails(forOrderWithId orderId: OrderSummary.ID) async -> BrickLinkOrder {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)")!)
    }
    
    
    static func updateStatus(ofOrderWithId orderId: OrderSummary.ID, to status: OrderStatus) async {
        
        try! await send(withMethod: .PUT, to: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/status")!) {
            """
            {
                "field" : "status",
                "value" : "\(status.rawValue)"
            }
            """
        }
    }
    
    
    static func updateTrackingNo(ofOrderWithId orderId: OrderSummary.ID, to trackingNo: String) async {
        
        try! await send(withMethod: .PUT, to: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)")!) {
            """
            {
                "shipping": {
                    "tracking_no": "\(trackingNo)"
                }
            }
            """
        }
    }
    
    
    static func sendDriveThru(forOrderWithId orderId: OrderSummary.ID, mailMe: Bool) async {
        
        let url = URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/drive_thru?mail_me=\(mailMe ? "true" : "false")")!
        
        try! await send(withMethod: .POST, to: url)
    }
    
    
    
    // MARK: - Order items
    
    
    static func fetchItems(forOrderWithId orderId: OrderSummary.ID) async -> [[BrickLinkOrderItem]] {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/items")!)
    }
    
    
    
    // MARK: - Order feedbacks
    
    
    static func fetchFeedbacks(forOrderWithId orderId: OrderSummary.ID) async -> [BrickLinkOrderFeedback] {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/feedback")!)
    }
    
    
    static func postFeedback(forOrderWithId orderId: OrderSummary.ID, rating: Int, comment: String) async {
        
        try! await send(withMethod: .POST, to: URL(string: "https://api.bricklink.com/api/store/v1/feedback")!) {
            """
            {
                "order_id": \(orderId),
                "rating": \(rating),
                "comment": "\(comment)"
            }
            """
        }
    }
    
    
    
    // MARK: - Inventory
        
        
    static func fetchInventories(matchingItemType itemType: BrickLinkItemType? = nil, matchingColorId colorId: String? = nil) async -> [BrickLinkInventoryItem] {
        
        var url = URL(string: "https://api.bricklink.com/api/store/v1/inventories")!
        if let itemType = itemType {
            url.append(queryItems: [.init(name: "item_type", value: itemType.rawValue)])
        }
        if let colorId = colorId {
            url.append(queryItems: [.init(name: "color_id", value: colorId)])
        }
        
        return try! await fetchAndDecodeData(from: url)
    }
    
    
    static func fetchInventory(withId id: InventoryItem.ID) async -> BrickLinkInventoryItem {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/inventories/\(id)")!)
    }
    
    
    static func createInventory(
        
        ref: String,
        type: BrickLinkItemType,
        colorId: String,
        quantity: Int,
        unitPrice: Float,
        condition: String,
        description: String?,
        remarks: String
        
    ) async -> BrickLinkInventoryItem {
        
        return try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/inventories")!, withMethod: .POST) {
            """
            {
                "item": {
                    "no": "\(ref)",
                    "type": "\(type.rawValue)"
                },
                "color_id": \(colorId),
                "quantity": \(quantity),
                "unit_price": "\(unitPrice)",
                "new_or_used": "\(condition)",
                "is_retain": false,
                "is_stock_room": false,
                "description": "\(description ?? "")",
                "remarks": "\(remarks)"
            }
            """
        }
    }
    
    
    static func updateInventory(
        
        id: InventoryItem.ID,
        
        addQuantity: Int,
        unitPrice: Float? = nil,
        remarks: String? = nil
        
    ) async {
        
        try! await send(withMethod: .PUT, to: URL(string: "https://api.bricklink.com/api/store/v1/inventories/\(id)")!) {
            
            var body = """
            {
                "quantity": "+\(addQuantity)"
            """
            
            if let price = unitPrice {
                
                body += """
                    ,"unit_price": "\(price)"
                """
            }
            if let remarks = remarks {
                
                body += """
                    ,"remarks": "\(remarks)"
                """
            }
            
            body += """
            }
            """
            
            return body
        }
    }
}
