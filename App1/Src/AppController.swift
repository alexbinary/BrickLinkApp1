
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
                { await self.loadMissingOrders() },
                { await self.refreshAllOrders() },
            ])
        }
    }
    
    
    
    // MARK: - Colors
    
    
    public var allColors: [LegoColor] {
        
        dataStore.colors
    }
    
    
    public func color(forLegoColorId colorId: LegoColor.ID) -> Color? {
        
        if let c = dataStore.colors.first(where: { $0.id == colorId }) {
            return Color(fromBLCode: c.colorCode)
        } else {
            return nil
        }
    }
    
    
    public func color(for item: OrderItem) -> Color? {
        
        return color(forLegoColorId: item.colorId)
    }
    
    
    public func colorName(forLegoColorId colorId: LegoColor.ID) -> String {
        
        return dataStore.colors.first(where: { $0.id == colorId })?.name ?? "\(colorId)"
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
    
    
    public func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        dataStore.orderSummaries.first { $0.id == orderId }
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
                .map { OrderSummary(fromBl: $0) }
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
    
    
    public var orderDetails: [OrderDetails] {
        
        dataStore.orderDetails
    }
    
    
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
            
            let order = OrderDetails(fromBl: blOrder)
            
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
    
    
    public func updateOrderStatus(orderId: OrderSummary.ID, status: OrderStatus) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/status")!)
        request.httpMethod = "PUT"
        request.httpBody = """
            {
                "field" : "status",
                "value" : "\(status.rawValue)"
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
    
    
    public func imageUrl(forItemType type: BrickLinkItemType, ref: String, colorId: String) -> URL? {
        
        switch type {
        case .part:
            return imageUrl(forPartWithRef: ref, colorId: colorId)
        case .minifig:
            return imageUrl(forMinifigWithRef: ref)
        }
    }
    
    
    public func imageUrl(forPartWithRef ref: String, colorId: String) -> URL? {
        
        return URL(string: "https://img.bricklink.com/P/\(colorId)/\(ref).jpg")
    }
    
    
    public func imageUrl(forMinifigWithRef ref: String) -> URL? {
        
        return URL(string: "https://img.bricklink.com/M/\(ref).jpg")
    }
    
    
    public func imageUrl(for item: OrderItem) -> URL? {
        
        return imageUrl(forItemType: item.type, ref: item.ref, colorId: item.colorId)
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
        
        dataStore.orderFeedbacksByOrderId[orderId] ?? []
    }
    
    
    private func loadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order feedbacks \(orderId)")
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/orders/\(orderId)/feedback")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkOrderFeedback]> = data.decode()
        if let blFeedbacks = decoded.data {
            
            let feedbacks = blFeedbacks.map { Feedback(fromBl: $0) }
            
            var orderFeedbacksByOrderId = dataStore.orderFeedbacksByOrderId
            orderFeedbacksByOrderId[orderId] = feedbacks
            
            try! dataStore.setOrderFeedbacksByOrderId(orderFeedbacksByOrderId)
            try! dataStore.save()
            
            DispatchQueue.main.sync {
                self.objectWillChange.send()
            }
        }
    }
    
    
    public func loadOrderFeedbacksIfMissing(forOrderWithId orderId: OrderSummary.ID) async {
        
        if !dataStore.orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func reloadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        if dataStore.orderFeedbacksByOrderId.keys.contains(orderId) {
            
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
    
    
    
    // MARK: - Upload
    
    
    public var uploadItems: [UploadItem] {
        
        dataStore.uploadItems
    }
    
    
    public func addUploadItem(_ uploadItem: UploadItem) {
        
        var uploadItems = dataStore.uploadItems
        uploadItems.append(uploadItem)
        
        try! dataStore.setUploadItems(uploadItems)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    public func deleteUploadItem(_ uploadItem: UploadItem) {
        
        var uploadItems = dataStore.uploadItems
        uploadItems.removeAll(where: { $0.id == uploadItem.id })
        
        try! dataStore.setUploadItems(uploadItems)
        try! dataStore.save()
        
        self.objectWillChange.send()
    }
    
    
    
    // MARK: - Inventory
    
    
    public func getInventory(for item: UploadItem) async -> InventoryItem? {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/inventories?item_type=\(item.type.rawValue)&color_id=\(item.colorId)")!)
        request.addAuthentication(using: blCredentials)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
        let decoded: BrickLinkAPIResponse<[BrickLinkInventoryItem]> = data.decode()
        if let inventories = decoded.data {
            
            if let inv = inventories.first(where: { inv in
                
                inv.item.type == item.type
                && inv.item.no == item.ref
                && "\(inv.colorId)" == item.colorId
            }) {
                return InventoryItem(fromBl: inv)
            }
        }
        
        return nil
    }
    
    
    public func createInventory(
        
        ref: String,
        type: BrickLinkItemType,
        colorId: String,
        quantity: Int,
        unitPrice: Float,
        condition: String,
        description: String,
        remarks: String
        
    ) async {
        
        var request = URLRequest(url: URL(string: "https://api.bricklink.com/api/store/v1/inventories")!)
        request.httpMethod = "POST"
        request.httpBody = """
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
                "description": "\(description)",
                "remarks": "\(remarks)"
            }
            """.data(using: .utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.addAuthentication(using: blCredentials)
        
        print(String(data: request.httpBody!, encoding: .utf8)!)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
    }
    
    
    public func updateInventory(
        
        id: InventoryItem.ID,
        
        addQuantity: Int,
        unitPrice: Float? = nil,
        remarks: String? = nil
    
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
        request.addAuthentication(using: blCredentials)
        
        print(String(data: request.httpBody!, encoding: .utf8)!)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
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
    
    
    public func incomeTransaction(forOrderWithId orderId: OrderDetails.ID) -> Transaction? {
        
        return transactions.first(where: { $0.type == .orderIncome && $0.orderRefIn == orderId })
    }
    
    
    public func shippingTransaction(forOrderWithId orderId: OrderDetails.ID) -> Transaction? {
        
        return transactions.first(where: { $0.type == .orderShipping && $0.orderRefIn == orderId })
    }
    
    
    
    // MARK: - Import & Refresh
    
    
    private func loadMissingOrders() async {
        
        for order in orderSummaries {
            
            await loadOrderDetailsIfMissing(forOrderWithId: order.id)
            await loadOrderItemsIfMissing(forOrderWithId: order.id)
            await loadOrderFeedbacksIfMissing(forOrderWithId: order.id)
        }
    }
    
    
    public func refreshAllOrders() async {
        
        await self.loadOrderSummaries()
        
        for order in orderSummaries {
            
            await refreshOrder(orderId: order.id)
        }
    }
    
    
    public func refreshOrder(orderId: OrderSummary.ID) async {
        
        if shouldRefreshOrder(orderId: orderId) {
            
            await loadOrderDetails(forOrderWithId: orderId)
            await loadOrderItems(forOrderWithId: orderId)
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func forceRefreshOrder(orderId: OrderSummary.ID) async {
        
        await loadOrderDetails(forOrderWithId: orderId)
        await loadOrderItems(forOrderWithId: orderId)
        await loadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    private func orderIsClosedForMoreThan30Days(orderId: OrderSummary.ID) -> Bool {
        
        let orderSummary = orderSummary(forOrderWithId: orderId)!
        
        return
            orderSummary.status.isOneOf([.completed, .cancelled, .purged])
            &&
            orderSummary.dateStatusChanged.days(to: Date()) > 30
    }
    
    
    private func shouldRefreshOrder(orderId: OrderSummary.ID) -> Bool {
        
        if !orderIsClosedForMoreThan30Days(orderId: orderId) {
            
            return true
        }
        
        guard
            let orderDetails = orderDetails(forOrderWithId: orderId)
        else {
            return true
        }
        
        let orderItems = orderItems(forOrderWithId: orderId)
        if orderItems.isEmpty {
            
            return true
        }
        
        let orderSummary = orderSummary(forOrderWithId: orderId)!
        if orderDetails.differs(from: orderSummary) {
            
            return true
        }
        
        let feedbacks = orderFeedbacks(forOrderWithId: orderId)
        
        if !feedbacks.hasSellerFeedback() {
            
            return true
        }
        
        return false
    }
    
    
    
    // MARK: - Profit margin
    
    
    public func profitMargin(for order: OrderDetails) -> Float? {
        
        return profitMargin(
            
            totalItems: order.subTotal,
            totalShipping: order.shippingCost,
        
            itemsCost: 0,
            shippingCost: shippingCost(forOrderWithId: order.id),
            fees: fees(for: order)
        )
    }
    
    
    public func profitMargin(
    
        totalItems: Float?,
        totalShipping: Float?,
    
        itemsCost: Float?,
        shippingCost: Float?,
        fees: Float?
        
    ) -> Float? {
        
        if
            let totalItems = totalItems,
            let totalShipping = totalShipping,
            
            let itemsCost = itemsCost,
            let shippingCost = shippingCost,
            let fees = fees
        {
            let totalIncome = totalItems + totalShipping
            let totalExpense = itemsCost + shippingCost + fees
            
            return (totalIncome - totalExpense) / totalIncome
        }
        
        return nil
    }
    
    
    public func fees(for order: OrderDetails) -> Float? {
        
        if let transactionAmount = incomeTransaction(forOrderWithId: order.id)?.amount {
            return order.grandTotal - transactionAmount
        }
        return nil
    }
}



extension OrderSummary {
    
    
    init(fromBl bl: BrickLinkOrder) {
        
        self.id = "\(bl.orderId)"
        self.date = bl.dateOrdered
        self.buyer = bl.buyerName
        self.items = bl.totalCount
        self.lots = bl.uniqueCount
        
        self.subTotal = bl.cost.subtotal.floatValue
        self.grandTotal = bl.cost.grandTotal.floatValue
        self.costCurrencyCode = bl.cost.currencyCode
        
        self.dispSubTotal = bl.dispCost.subtotal.floatValue
        self.dispGrandTotal = bl.dispCost.grandTotal.floatValue
        self.dispCostCurrencyCode = bl.dispCost.currencyCode
        
        self.status = OrderStatus(rawValue: bl.status)!
        self.dateStatusChanged = bl.dateStatusChanged
    }
}


extension OrderDetails {
    
    
    init(fromBl bl: BrickLinkOrder) {
        
        self.id = "\(bl.orderId)"
        self.date = bl.dateOrdered
        self.buyer = bl.buyerName
        self.items = bl.totalCount
        self.lots = bl.uniqueCount
        
        self.subTotal = bl.cost.subtotal.floatValue
        self.grandTotal = bl.cost.grandTotal.floatValue
        self.shippingCost = bl.cost.shipping!.floatValue
        self.costCurrencyCode = bl.cost.currencyCode
        
        self.dispSubTotal = bl.dispCost.subtotal.floatValue
        self.dispGrandTotal = bl.dispCost.grandTotal.floatValue
        self.dispShippingCost = bl.dispCost.shipping!.floatValue
        self.dispCostCurrencyCode = bl.dispCost.currencyCode
        
        self.status = OrderStatus(rawValue: bl.status)!
        self.driveThruSent = bl.driveThruSent!
        self.trackingNo = bl.shipping!.trackingNo
        self.totalWeight = bl.totalWeight!.floatValue
        
        self.shippingMethodId = bl.shipping!.methodId
        self.shippingMethodName = bl.shipping!.method
        self.shippingAddress = bl.shipping!.address.full
        self.shippingAddressCountryCode = bl.shipping!.address.countryCode
        self.shippingAddressName = bl.shipping!.address.name.full
    }
}


extension InventoryItem {
    
    
    init(fromBl bl: BrickLinkInventoryItem) {
        
        self.id = "\(bl.inventoryId)"
        self.condition = bl.newOrUsed
        self.colorId = "\(bl.colorId)"
        self.ref = bl.item.no
        self.name = bl.item.name
        self.type = bl.item.type
        self.description = bl.description ?? ""
        self.remarks = bl.remarks ?? ""
        self.quantity = bl.quantity
        self.unitPrice = bl.unitPrice.floatValue
    }
}


extension Feedback {
    
    
    init(fromBl bl: BrickLinkOrderFeedback) {
        
        self.id = bl.feedbackId
        self.orderId = "\(bl.orderId)"
        self.from = bl.from
        self.to = bl.to
        self.dateRated = bl.dateRated
        self.rating = bl.rating
        self.author = FeedbackAuthor(fromBl: bl.ratingOfBs)!
        self.comment = bl.comment
    }
}


extension FeedbackAuthor {
    
    
    init?(fromBl ratingOfBs: String) {
        
        switch ratingOfBs {
          
        case "B": self = .seller
        case "S": self = .buyer
            
        default: return nil
        }
    }
}


extension Data {
    
    
    func decode<T>() -> T where T: Decodable {
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        decoder.dateDecodingStrategy = .custom({ (decoder) in
            
            let stringValue = try! decoder.singleValueContainer().decode(String.self)
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
            
            return dateFormatter.date(from: stringValue)!
        })
        
        let decoded = try! decoder.decode(T.self, from: self)
        
        return decoded
    }
}
