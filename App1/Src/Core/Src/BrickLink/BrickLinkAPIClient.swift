
import Foundation



@MainActor
struct BrickLinkAPIClient {
    
    
    let credentials: BrickLinkAPICredentials
    let debug: Debug
    
    
    init(withCredentials credentials: BrickLinkAPICredentials, debug: Debug) {
        
        self.credentials = credentials
        self.debug = debug
    }
    
    
    // MARK: - Infra
    
    
    enum Method: String {
        
        case PUT="PUT"
        case POST="POST"
    }
    
    
    @discardableResult
    private func send(withMethod method: Method? = nil, to url: URL, body: ()->String? = {nil}) async throws -> (Data, URLResponse) {
        
        var request = URLRequest(url: url)
        
        if let method = method {
            request.httpMethod = method.rawValue
        }
        if let body = body() {
            request.httpBody = body.data(using: .utf8)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
        }
        
        request.addAuthentication(using: credentials)

        debug.printRequest(request)
        
        let (data, response) = try! await URLSession(configuration: .default).data(for: request)
        
        debug.printResponse(data, response)
        
        return (data, response)
    }
    
    
    private let decoder = {
        
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
    
    
    private func fetchAndDecodeData<T: Decodable>(from url: URL, withMethod method: Method? = nil, body: ()->String? = {nil}) async throws -> T {
        
        let (data, _) = try! await send(withMethod: method, to: url, body: body)
        
        let decoded = try! decoder.decode(BrickLinkAPIResponse<T>.self, from: data)
        return decoded.data!
    }
    
    
    
    // MARK: - Catalog
        
        
    func fetchColors() async -> [BrickLinkColor] {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/colors")!)
    }
    
    
    func fetchCatalogEntry(forItemType type: BrickLinkItemType, ref: String) async -> BrickLinkCatalogItem? {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/items/\(type.rawValue)/\(ref)")!)
    }
    
    
    
    // MARK: - Orders
    
    
    func fetchOrderSummaries() async -> [BrickLinkOrderSummary] {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/orders")!)
    }
    
    
    func fetchDetails(forOrderWithId orderId: OrderSummary.ID) async -> BrickLinkOrderDetails {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)")!)
    }
    
    
    func updateStatus(ofOrderWithId orderId: OrderSummary.ID, to status: OrderStatus) async {
        
        try! await send(withMethod: .PUT, to: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/status")!) {
            """
            {
                "field" : "status",
                "value" : "\(status.rawValue)"
            }
            """
        }
    }
    
    
    func updateTrackingNo(ofOrderWithId orderId: OrderSummary.ID, to trackingNo: String) async {
        
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
    
    
    func sendDriveThru(forOrderWithId orderId: OrderSummary.ID, mailMe: Bool) async {
        
        let url = URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/drive_thru?mail_me=\(mailMe ? "true" : "false")")!
        
        try! await send(withMethod: .POST, to: url)
    }
    
    
    
    // MARK: - Order items
    
    
    func fetchItems(forOrderWithId orderId: OrderSummary.ID) async -> [[BrickLinkOrderItem]] {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/items")!)
    }
    
    
    
    // MARK: - Order feedbacks
    
    
    func fetchFeedbacks(forOrderWithId orderId: OrderSummary.ID) async -> [BrickLinkOrderFeedback] {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/feedback")!)
    }
    
    
    func postFeedback(forOrderWithId orderId: OrderSummary.ID, rating: Int, comment: String) async {
        
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
        
        
    func fetchInventories(matchingItemType itemType: BrickLinkItemType? = nil, matchingColorId colorId: String? = nil) async -> [BrickLinkInventoryItem] {
        
        var url = URL(string: "https://api.bricklink.com/api/store/v1/inventories")!
        if let itemType = itemType {
            url.append(queryItems: [.init(name: "item_type", value: itemType.rawValue)])
        }
        if let colorId = colorId {
            url.append(queryItems: [.init(name: "color_id", value: colorId)])
        }
        
        return try! await fetchAndDecodeData(from: url)
    }
    
    
    func fetchInventory(withId id: InventoryItem.ID) async -> BrickLinkInventoryItem {
        
        try! await fetchAndDecodeData(from: URL(string: "https://api.bricklink.com/api/store/v1/inventories/\(id)")!)
    }
    
    
    func createInventory(
        
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
    
    
    func updateInventory(
        
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
