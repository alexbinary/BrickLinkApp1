
import Foundation



struct BrickLinkAPIClient {
    
    
    // MARK: - Catalog
        
        
    static func fetchColors(using credentials: BrickLinkAPICredentials) async -> [BrickLinkColor] {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/colors")!)
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkColor]> = data.decode()
        let colors = decoded.data!
        
        return colors
    }
    
    
    static func fetchCatalogEntry(forItemType type: BrickLinkItemType, ref: String, using credentials: BrickLinkAPICredentials) async -> BrickLinkCatalogItem? {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/items/\(type.rawValue)/\(ref)")!)
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<BrickLinkCatalogItem> = data.decode()
        let catalogItem = decoded.data
        
        return catalogItem
    }
    
    
    static func url(forCatalogImageOfPartWithRef ref: String, colorId: String) -> URL? {
        
        return URL(string: "https://img.bricklink.com/P/\(colorId)/\(ref).jpg")
    }
    
    
    static func url(forCalalogImageOfMinifigWithRef ref: String) -> URL? {
        
        return URL(string: "https://img.bricklink.com/M/\(ref).jpg")
    }
    
    
    // MARK: - Orders
    
    
    static func url(forDetailsOfOrderWithId orderId: String) -> URL? {
        
        return URL(string: "https://www.bricklink.com/orderDetail.asp?ID=\(orderId)#/")
    }
        
        
    static func fetchOrderSummaries(using credentials: BrickLinkAPICredentials) async -> [BrickLinkOrder] {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders")!)
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkOrder]> = data.decode()
        let orders = decoded.data!
        
        return orders
    }
    
    
    static func fetchDetails(forOrderWithId orderId: OrderSummary.ID, using credentials: BrickLinkAPICredentials) async -> BrickLinkOrder {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)")!)
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<BrickLinkOrder> = data.decode()
        let order = decoded.data!
        
        return order
    }
    
    
    static func updateStatus(ofOrderWithId orderId: OrderSummary.ID, to status: OrderStatus, using credentials: BrickLinkAPICredentials) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/status")!)
        request.httpMethod = "PUT"
        request.httpBody = """
        {
            "field" : "status",
            "value" : "\(status.rawValue)"
        }
        """.data(using: .utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
    }
    
    
    static func updateTrackingNo(ofOrderWithId orderId: OrderSummary.ID, to trackingNo: String, using credentials: BrickLinkAPICredentials) async {
        
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
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
    }
    
    
    static func sendDriveThru(forOrderWithId orderId: OrderSummary.ID, using credentials: BrickLinkAPICredentials, mailMe: Bool) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/drive_thru?mail_me=\(mailMe ? "true" : "false")")!)
        request.httpMethod = "POST"
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
    }
    
    
    // MARK: - Order items
    
    
    static func fetchItems(forOrderWithId orderId: OrderSummary.ID, using credentials: BrickLinkAPICredentials) async -> [[BrickLinkOrderItem]] {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/items")!)
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[[BrickLinkOrderItem]]> = data.decode()
        let batches = decoded.data!
        
        return batches
    }
    
    
    // MARK: - Order feedbacks
    
    
    static func fetchFeedbacks(forOrderWithId orderId: OrderSummary.ID, using credentials: BrickLinkAPICredentials) async -> [BrickLinkOrderFeedback] {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/feedback")!)
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkOrderFeedback]> = data.decode()
        let feedbacks = decoded.data!
        
        return feedbacks
    }
    
    
    static func postFeedback(forOrderWithId orderId: OrderSummary.ID, rating: Int, comment: String, using credentials: BrickLinkAPICredentials) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/feedback")!)
        request.httpMethod = "POST"
        request.httpBody = """
            {
                "order_id": \(orderId),
                "rating": \(rating),
                "comment": "\(comment)"
            }
            """.data(using: .utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.addAuthentication(using: credentials)
        
        print(String(data: request.httpBody!, encoding: .utf8)!)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
    }
    
    
    // MARK: - Inventory
        
        
    static func fetchInventories(matchingItemType itemType: BrickLinkItemType? = nil, matchingColorId colorId: String? = nil, using credentials: BrickLinkAPICredentials) async -> [BrickLinkInventoryItem] {
        
        var url = URL(string: "https://api.bricklink.com/api/store/v1/inventories")!
        if let itemType = itemType {
            url.append(queryItems: [.init(name: "item_type", value: itemType.rawValue)])
        }
        if let colorId = colorId {
            url.append(queryItems: [.init(name: "color_id", value: colorId)])
        }
        
        var request = URLRequest(url: url)
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkInventoryItem]> = data.decode()
        let inventories = decoded.data!
        
        return inventories
    }
    
    
    static func fetchInventory(withId id: InventoryItem.ID, using credentials: BrickLinkAPICredentials) async -> BrickLinkInventoryItem {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/inventories/\(id)")!)
        request.addAuthentication(using: credentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<BrickLinkInventoryItem> = data.decode()
        let inventory = decoded.data!
        
        return inventory
    }
    
    
    static func createInventory(
        
        ref: String,
        type: BrickLinkItemType,
        colorId: String,
        quantity: Int,
        unitPrice: Float,
        condition: String,
        description: String?,
        remarks: String,
        
        using credentials: BrickLinkAPICredentials
        
    ) async -> BrickLinkInventoryItem {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/inventories")!)
        request.httpMethod = "POST"
        let body = """
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
        request.httpBody = body.data(using: .utf8)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.addAuthentication(using: credentials)
        
        print(String(data: request.httpBody!, encoding: .utf8)!)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<BrickLinkInventoryItem> = data.decode()
        let inventory = decoded.data!
        
        return inventory
    }
    
    
    static func updateInventory(
        
        id: InventoryItem.ID,
        
        addQuantity: Int,
        unitPrice: Float? = nil,
        remarks: String? = nil,
        
        using credentials: BrickLinkAPICredentials
        
    ) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/inventories/\(id)")!)
        request.httpMethod = "PUT"
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
        request.httpBody = body.data(using: .utf8)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.addAuthentication(using: credentials)
        
        print(String(data: request.httpBody!, encoding: .utf8)!)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
    }
}
