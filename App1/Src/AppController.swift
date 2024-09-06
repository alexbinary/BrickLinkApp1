
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
        
        Task {
            await self.loadColors()
            await self.loadOrderSummaries()
        }
    }
    
    
    // MARK: - Colors
    
    
    private var legoColors: [LegoColor] = []
    
    
    public func color(for item: OrderItem) -> Color? {
        
        if let c = legoColors.first(where: { $0.id == item.colorId }) {
            return Color(fromBLCode: c.colorCode)
        } else {
            return nil
        }
    }
    
    
    public func colorName(for item: OrderItem) -> String {
        
        item.colorName
    }
    
    
    private func loadColors() async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/colors")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkColor]> = data.decode()
        if let blColors = decoded.data {
            
            self.legoColors = blColors.map {
                LegoColor(
                    id: "\($0.colorId)",
                    name: $0.colorName,
                    colorCode: $0.colorCode
                )
            }
            DispatchQueue.main.sync {
                self.objectWillChange.send()
            }
        }
    }
    
    
    
    // MARK: - Order summaries
    
    
    private var orderSummaries: [OrderSummary] = []
    
    
    public var allOrderSummaries: [OrderSummary] {
        
        orderSummaries
    }
    
    
    private func loadOrderSummaries() async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkOrder]> = data.decode()
        if let blOrders = decoded.data {
            
            self.orderSummaries = blOrders
                .map { OrderSummary(fromBlOrder: $0) }
                .sorted { $0.date > $1.date }
            
            DispatchQueue.main.sync {
                self.objectWillChange.send()
            }
        }
    }
    
    
    public func loadOrderSummariesIfMissing() async {
        
        if orderSummaries.isEmpty {
        
            await loadOrderSummaries()
        }
    }
    
    
    public func reloadOrderSummaries() async {
        
        if !orderSummaries.isEmpty {
        
            await loadOrderSummaries()
        }
    }
    
    
    
    // MARK: - Orders details
    
    
    private var orderDetails: [OrderDetails] = []
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderDetails.first { $0.id == orderId }
    }
    
    
    private func loadOrderDetails(orderId: String) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<BrickLinkOrder> = data.decode()
        if let blOrder = decoded.data {
            
            let order = OrderDetails(fromBlOrder: blOrder)
            
            if let index = self.orderDetails.firstIndex(where: { $0.id == order.id }) {
                self.orderDetails[index] = order
            } else {
                self.orderDetails.append(order)
            }
            
            DispatchQueue.main.sync {
                self.objectWillChange.send()
            }
        }
    }
    
    
    public func loadOrderDetailsIfMissing(orderId: String) async {
        
        if !self.orderDetails.contains(where: { $0.id == orderId }) {
            
            await loadOrderDetails(orderId: orderId)
        }
    }
    
    
    public func reloadOrderDetails(orderId: String) async {
        
        if self.orderDetails.contains(where: { $0.id == orderId }) {
            
            await loadOrderDetails(orderId: orderId)
        }
    }
    
    
    
    // MARK: - Order status, Tracking no, Drive thru
    
    
    public func updateOrderStatus(orderId: OrderId, status: String) async {
        
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
        
        await reloadOrderSummaries()
        await reloadOrderDetails(orderId: orderId)
    }
    
    
    public func updateTrackingNo(forOrderWithId orderId: OrderId, trackingNo: String) async {
        
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
        
        await reloadOrderSummaries()
        await reloadOrderDetails(orderId: orderId)
    }


    public func sendDriveThru(orderId: OrderId) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/drive_thru?mail_me=true")!)
        request.httpMethod = "POST"
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        await reloadOrderSummaries()
        await reloadOrderDetails(orderId: orderId)
    }
    
    
    
    // MARK: - Shipping cost
    
    
    public func shippingCost(forOrderWithId orderId: OrderId) -> Float? {
        
        return dataStore.shippingCostsByOrderId[orderId]
    }
    
    
    public func updateShippingCost(forOrderWithId orderId: OrderId, cost: Float) {
        
        var shippingCostsByOrderId = dataStore.shippingCostsByOrderId
        
        shippingCostsByOrderId[orderId] = cost
        
        try! dataStore.setShippingCostsByOrderId(shippingCostsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    
    // MARK: - Affranchissement
    
    
    public func affranchissement(forOrderWithId orderId: OrderId) -> String? {
        
        return dataStore.affranchissementMethodByOrderId[orderId]
    }
    
    
    public func updateAffranchissement(forOrderWithId orderId: OrderId, method: String) {
        
        var affranchissementMethodByOrderId = dataStore.affranchissementMethodByOrderId
        
        affranchissementMethodByOrderId[orderId] = method
        
        try! dataStore.setAffranchissementMethodByOrderId(affranchissementMethodByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    
    // MARK: - Order items
    
    
    public func getOrderItems(orderId: OrderId) async -> [OrderItem] {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/items")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[[BrickLinkOrderItem]]> = data.decode()
        if let batches = decoded.data, let items = batches.first {
            
            return items.map { item in
                
                OrderItem(
                    id: "\(item.inventoryId)",
                    orderId: orderId,
                    condition: item.newOrUsed,
                    colorId: "\(item.colorId)",
                    colorName: item.colorName,
                    ref: item.item.no,
                    name: item.item.name,
                    type: item.item.type,
                    location: item.remarks ?? "",
                    comment: item.description ?? "",
                    quantity: "\(item.quantity)",
                    quantityLeft: "",
                    unitPrice: item.unitPrice.floatValue,
                    unitPriceFinal: item.unitPriceFinal.floatValue
                )
            }
        }
        
        return []
    }
    
    
    public func imageUrl(item: OrderItem) -> URL? {
        
        switch item.type {
        case .part:
            return URL(string: "https://img.bricklink.com/P/\(item.colorId)/\(item.ref).jpg")
        case .minifig:
            return URL(string: "https://img.bricklink.com/M/\(item.ref).jpg")
        }
    }
    
    
    public func pickedItems(forOrderWithId orderId: OrderId) -> [InventoryId] {
        
        return dataStore.pickedItemsByOrderId[orderId] ?? []
    }
    
    
    public func pickItem(forOrderWithId orderId: OrderId, item itemId: InventoryId) {
        
        var pickedItemsByOrderId = dataStore.pickedItemsByOrderId
        var pickedItemsForOrder = dataStore.pickedItemsByOrderId[orderId] ?? [InventoryId]()
        
        guard !pickedItemsForOrder.contains(itemId) else { return }
            
        pickedItemsForOrder.append(itemId)
        pickedItemsByOrderId[orderId] = pickedItemsForOrder
        
        try! dataStore.setPickedItemsByOrderId(pickedItemsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    public func unpickItem(forOrderWithId orderId: OrderId, item itemId: InventoryId) {
        
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
    
    
    public func verifiedItems(forOrderWithId orderId: OrderId) -> [InventoryId] {
        
        return dataStore.verifiedItemsByOrderId[orderId] ?? []
    }
    
    
    public func verifyItem(forOrderWithId orderId: OrderId, item itemId: InventoryId) {
        
        var verifiedItemsByOrderId = dataStore.verifiedItemsByOrderId
        var verifiedItemsForOrder = dataStore.verifiedItemsByOrderId[orderId] ?? [InventoryId]()
        
        guard !verifiedItemsForOrder.contains(itemId) else { return }
            
        verifiedItemsForOrder.append(itemId)
        verifiedItemsByOrderId[orderId] = verifiedItemsForOrder
        
        try! dataStore.setVerifiedItemsByOrderId(verifiedItemsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    public func unverifyItem(forOrderWithId orderId: OrderId, item itemId: InventoryId) {
        
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
    
    
    
    // MARK: - Order feedback
    
    
    private var orderFeedbacksByOrderId: [OrderSummary.ID: [Feedback]] = [:]
    
    
    public func orderFeedbacks(forOrderWithId orderId: String) -> [Feedback] {
        
        orderFeedbacksByOrderId[orderId] ?? []
    }
    
    
    private func loadOrderFeedbacks(forOrderWithId orderId: String) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/feedback")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkOrderFeedback]> = data.decode()
        if let blFeedbacks = decoded.data {
            
            orderFeedbacksByOrderId[orderId] = blFeedbacks.map { Feedback(fromBlFeedback: $0) }
            
            DispatchQueue.main.sync {
                self.objectWillChange.send()
            }
        }
    }
    
    
    public func loadOrderFeedbacksIfMissing(forOrderWithId orderId: String) async {
        
        if !orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func reloadOrderFeedbacks(forOrderWithId orderId: String) async {
        
        if orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func postOrderFeedback(orderId: String, rating: Int, comment: String) async {
        
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
        request.addAuthentication(using: blCredentials)
        
        print(String(data: request.httpBody!, encoding: .utf8)!)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        await reloadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    
    // MARK: - Transactions
    
    
    public var transactions: [Transaction] {
        
        dataStore.transactions
    }
    
    
    public func registerTransaction(_ transaction: Transaction) {
        
        var transactions = dataStore.transactions
        transactions.append(transaction)
        
        try! dataStore.setTransactions(transactions)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
}



extension OrderSummary {
    
    
    init(fromBlOrder blOrder: BrickLinkOrder) {
        
        self.id = "\(blOrder.orderId)"
        self.date = blOrder.dateOrdered
        self.buyer = blOrder.buyerName
        self.items = blOrder.totalCount
        self.lots = blOrder.uniqueCount
        
        self.subTotal = blOrder.cost.subtotal.floatValue
        self.grandTotal = blOrder.cost.grandTotal.floatValue
        self.costCurrencyCode = blOrder.cost.currencyCode
        
        self.dispSubTotal = blOrder.dispCost.subtotal.floatValue
        self.dispGrandTotal = blOrder.dispCost.grandTotal.floatValue
        self.dispCostCurrencyCode = blOrder.dispCost.currencyCode
        
        self.status = blOrder.status
    }
}


extension OrderDetails {
    
    
    init(fromBlOrder blOrder: BrickLinkOrder) {
        
        self.id = "\(blOrder.orderId)"
        self.date = blOrder.dateOrdered
        self.buyer = blOrder.buyerName
        self.items = blOrder.totalCount
        self.lots = blOrder.uniqueCount
        
        self.subTotal = blOrder.cost.subtotal.floatValue
        self.grandTotal = blOrder.cost.grandTotal.floatValue
        self.shippingCost = blOrder.cost.shipping!.floatValue
        self.costCurrencyCode = blOrder.cost.currencyCode
        
        self.dispSubTotal = blOrder.dispCost.subtotal.floatValue
        self.dispGrandTotal = blOrder.dispCost.grandTotal.floatValue
        self.dispShippingCost = blOrder.dispCost.shipping!.floatValue
        self.dispCostCurrencyCode = blOrder.dispCost.currencyCode
        
        self.status = blOrder.status
        self.driveThruSent = blOrder.driveThruSent!
        self.trackingNo = blOrder.shipping!.trackingNo
        self.totalWeight = blOrder.totalWeight!.floatValue
        
        self.shippingMethodId = blOrder.shipping!.methodId
        self.shippingMethodName = blOrder.shipping!.method
        self.shippingAddress = blOrder.shipping!.address.full
        self.shippingAddressCountryCode = blOrder.shipping!.address.countryCode
        self.shippingAddressName = blOrder.shipping!.address.name.full
    }
}


extension Feedback {
    
    
    init(fromBlFeedback blFeedback: BrickLinkOrderFeedback) {
        
        self.id = blFeedback.feedbackId
        self.from = blFeedback.from
        self.to = blFeedback.to
        self.dateRated = blFeedback.dateRated
        self.rating = blFeedback.rating
        self.ratingOfBs = blFeedback.ratingOfBs
        self.comment = blFeedback.comment
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
