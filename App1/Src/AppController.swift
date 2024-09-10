
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
            await parallel([
                { await self.loadColors() },
                { await self.loadOrderSummaries() },
            ])
        }
    }
    
    
    
    // MARK: - Colors
    
    
    public func color(for item: OrderItem) -> Color? {
        
        if let c = dataStore.colors.first(where: { $0.id == item.colorId }) {
            return Color(fromBLCode: c.colorCode)
        } else {
            return nil
        }
    }
    
    
    public func colorName(for item: OrderItem) -> String {
        
        item.colorName
    }
    
    
    private func loadColors() async {
        
        print("Loading colors")
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/colors")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkColor]> = data.decode()
        if let blColors = decoded.data {
            
            let colors = blColors.map {
                LegoColor(
                    id: "\($0.colorId)",
                    name: $0.colorName,
                    colorCode: $0.colorCode
                )
            }
            
            try! dataStore.setColors(colors)
            try! dataStore.save()
            
            DispatchQueue.main.sync {
                self.objectWillChange.send()
            }
        }
    }
    
    
    func loadColorsIfMissing() async {
        
        if dataStore.colors.isEmpty {
            
            await loadColors()
        }
    }
    
    
    func reloadColors() async {
        
        if !dataStore.colors.isEmpty {
            
            await loadColors()
        }
    }
    
    
    
    // MARK: - Order summaries
    
    
    public var orderSummaries: [OrderSummary] {
        
        dataStore.orderSummaries
    }
    
    
    private func loadOrderSummaries() async {
        
        print("Loading orders")
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkOrder]> = data.decode()
        if let blOrders = decoded.data {
            
            let orderSummaries = blOrders
                .map { OrderSummary(fromBlOrder: $0) }
                .sorted { $0.date > $1.date }
            
            try! dataStore.setOrderSummaries(orderSummaries)
            try! dataStore.save()
            
            DispatchQueue.main.sync {
                self.objectWillChange.send()
            }
        }
    }
    
    
    public func loadOrderSummariesIfMissing() async {
        
        if dataStore.orderSummaries.isEmpty {
        
            await loadOrderSummaries()
        }
    }
    
    
    public func reloadOrderSummaries() async {
        
        if !dataStore.orderSummaries.isEmpty {
        
            await loadOrderSummaries()
        }
    }
    
    
    
    // MARK: - Orders details
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        dataStore.orderDetails.first { $0.id == orderId }
    }
    
    
    private func loadOrderDetails(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order details \(orderId)")
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<BrickLinkOrder> = data.decode()
        if let blOrder = decoded.data {
            
            let order = OrderDetails(fromBlOrder: blOrder)
            
            var orderDetails = dataStore.orderDetails
            
            if let index = orderDetails.firstIndex(where: { $0.id == order.id }) {
                orderDetails[index] = order
            } else {
                orderDetails.append(order)
            }
            
            try! dataStore.setOrderDetails(orderDetails)
            try! dataStore.save()
            
            DispatchQueue.main.sync {
                self.objectWillChange.send()
            }
        }
    }
    
    
    public func loadOrderDetailsIfMissing(forOrderWithId orderId: String) async {
        
        if !dataStore.orderDetails.contains(where: { $0.id == orderId }) {
            
            await loadOrderDetails(forOrderWithId: orderId)
        }
    }
    
    
    public func reloadOrderDetails(forOrderWithId orderId: String) async {
        
        if dataStore.orderDetails.contains(where: { $0.id == orderId }) {
            
            await loadOrderDetails(forOrderWithId: orderId)
        }
    }
    
    
    
    // MARK: - Order status, Tracking no, Drive thru
    
    
    public func updateOrderStatus(orderId: OrderSummary.ID, status: String) async {
        
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
        
        await parallel([
            { await self.reloadOrderSummaries() },
            { await self.reloadOrderDetails(forOrderWithId: orderId) },
        ])
    }
    
    
    public func updateTrackingNo(forOrderWithId orderId: OrderSummary.ID, trackingNo: String) async {
        
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
        
        await parallel([
            { await self.reloadOrderSummaries() },
            { await self.reloadOrderDetails(forOrderWithId: orderId) },
        ])
    }


    public func sendDriveThru(orderId: OrderSummary.ID) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/drive_thru?mail_me=true")!)
        request.httpMethod = "POST"
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        await parallel([
            { await self.reloadOrderSummaries() },
            { await self.reloadOrderDetails(forOrderWithId: orderId) },
        ])
    }
    
    
    
    // MARK: - Shipping cost
    
    
    public func shippingCost(forOrderWithId orderId: OrderSummary.ID) -> Float? {
        
        return dataStore.shippingCostsByOrderId[orderId]
    }
    
    
    public func updateShippingCost(forOrderWithId orderId: OrderSummary.ID, cost: Float) {
        
        var shippingCostsByOrderId = dataStore.shippingCostsByOrderId
        
        shippingCostsByOrderId[orderId] = cost
        
        try! dataStore.setShippingCostsByOrderId(shippingCostsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    
    // MARK: - Affranchissement
    
    
    public func affranchissement(forOrderWithId orderId: OrderSummary.ID) -> String? {
        
        return dataStore.affranchissementMethodByOrderId[orderId]
    }
    
    
    public func updateAffranchissement(forOrderWithId orderId: OrderSummary.ID, method: String) {
        
        var affranchissementMethodByOrderId = dataStore.affranchissementMethodByOrderId
        
        affranchissementMethodByOrderId[orderId] = method
        
        try! dataStore.setAffranchissementMethodByOrderId(affranchissementMethodByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    
    // MARK: - Order items
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        (dataStore.orderItemsByOrderId[orderId] ?? []).reduce([], { $0 + $1 })
    }
    
    
    private func loadOrderItems(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order items \(orderId)")
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/items")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[[BrickLinkOrderItem]]> = data.decode()
        if let blBatches = decoded.data {
            
            let batches = blBatches.map { blItems in
                
                blItems.map { item in
                    
                    OrderItem(
                        inventoryId: "\(item.inventoryId)",
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
            
            var orderItemsByOrderId = dataStore.orderItemsByOrderId
            
            orderItemsByOrderId[orderId] = batches
            
            try! dataStore.setOrderItemsByOrderId(orderItemsByOrderId)
            try! dataStore.save()
            
            DispatchQueue.main.sync {
                self.objectWillChange.send()
            }
        }
    }
    
    
    public func loadOrderItemsIfMissing(forOrderWithId orderId: String) async {
        
        if !dataStore.orderItemsByOrderId.keys.contains(where: { $0 == orderId }) {
            
            await loadOrderItems(forOrderWithId: orderId)
        }
    }
    
    
    public func reloadOrderItems(forOrderWithId orderId: String) async {
        
        if dataStore.orderItemsByOrderId.keys.contains(where: { $0 == orderId }) {
            
            await loadOrderItems(forOrderWithId: orderId)
        }
    }
    
    
    public func imageUrl(item: OrderItem) -> URL? {
        
        switch item.type {
        case .part:
            return URL(string: "https://img.bricklink.com/P/\(item.colorId)/\(item.ref).jpg")
        case .minifig:
            return URL(string: "https://img.bricklink.com/M/\(item.ref).jpg")
        }
    }
    
    
    public func pickedItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        return dataStore.pickedItemsByOrderId[orderId] ?? []
    }
    
    
    public func pickItem(forOrderWithId orderId: OrderSummary.ID, item itemId: OrderItem.ID) {
        
        var pickedItemsByOrderId = dataStore.pickedItemsByOrderId
        var pickedItemsForOrder = dataStore.pickedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        guard !pickedItemsForOrder.contains(itemId) else { return }
            
        pickedItemsForOrder.append(itemId)
        pickedItemsByOrderId[orderId] = pickedItemsForOrder
        
        try! dataStore.setPickedItemsByOrderId(pickedItemsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    public func unpickItem(forOrderWithId orderId: OrderSummary.ID, item itemId: OrderItem.ID) {
        
        var pickedItemsByOrderId = dataStore.pickedItemsByOrderId
        var pickedItemsForOrder = dataStore.pickedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        pickedItemsForOrder.removeAll { $0 == itemId }
        pickedItemsByOrderId[orderId] = pickedItemsForOrder
        
        if pickedItemsByOrderId[orderId]!.isEmpty {
            pickedItemsByOrderId.removeValue(forKey: orderId)
        }
        
        try! dataStore.setPickedItemsByOrderId(pickedItemsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    public func verifiedItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        return dataStore.verifiedItemsByOrderId[orderId] ?? []
    }
    
    
    public func verifyItem(forOrderWithId orderId: OrderSummary.ID, item itemId: OrderItem.ID) {
        
        var verifiedItemsByOrderId = dataStore.verifiedItemsByOrderId
        var verifiedItemsForOrder = dataStore.verifiedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
        guard !verifiedItemsForOrder.contains(itemId) else { return }
            
        verifiedItemsForOrder.append(itemId)
        verifiedItemsByOrderId[orderId] = verifiedItemsForOrder
        
        try! dataStore.setVerifiedItemsByOrderId(verifiedItemsByOrderId)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    public func unverifyItem(forOrderWithId orderId: OrderSummary.ID, item itemId: OrderItem.ID) {
        
        var verifiedItemsByOrderId = dataStore.verifiedItemsByOrderId
        var verifiedItemsForOrder = dataStore.verifiedItemsByOrderId[orderId] ?? [OrderItem.ID]()
        
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
    
    
    public func orderFeedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        dataStore.orderFeedbacks.filter { $0.orderId == orderId }
    }
    
    
    private func loadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order feedbacks \(orderId)")
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/feedback")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkOrderFeedback]> = data.decode()
        if let blFeedbacks = decoded.data {
            
            let newFeedbacks = blFeedbacks.map { Feedback(fromBlFeedback: $0) }
            
            var feedbacks = dataStore.orderFeedbacks
            feedbacks.removeAll(where: { $0.orderId == newFeedbacks.first?.orderId })
            feedbacks.append(contentsOf: newFeedbacks)
            
            try! dataStore.setOrderFeedbacks(feedbacks)
            try! dataStore.save()
            
            DispatchQueue.main.sync {
                self.objectWillChange.send()
            }
        }
    }
    
    
    public func loadOrderFeedbacksIfMissing(forOrderWithId orderId: OrderSummary.ID) async {
        
        if !dataStore.orderFeedbacks.contains(where: { $0.orderId == orderId }) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func reloadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        if dataStore.orderFeedbacks.contains(where: { $0.orderId == orderId }) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func postOrderFeedback(orderId: OrderSummary.ID, rating: Int, comment: String) async {
        
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
        self.orderId = "\(blFeedback.orderId)"
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
