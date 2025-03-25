
import Foundation
import Core



class OrderCoreController {
    
    
    private let dataStore: DataStore
    private let brickLinkAPIClient: BrickLinkAPIClient
    
    
    init(_ dataStore: DataStore, _ brickLinkAPIClient: BrickLinkAPIClient) {
     
        self.dataStore = dataStore
        self.brickLinkAPIClient = brickLinkAPIClient
    }
    
    
    // MARK: - Order summaries
    
    
    public var orderSummaries: [OrderSummary] {
        
        dataStore.orderSummaries
    }
    
    
    public func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        orderSummaries.first { $0.id == orderId }
    }
    
    
    public func loadOrderSummaries() async {
        
        print("Loading orders")
        
        let blOrders = await brickLinkAPIClient.fetchOrderSummaries()
        let orderSummaries = blOrders.map { OrderSummary(fromBl: $0) }.sorted { $0.date > $1.date }
        
        print("loaded \(orderSummaries.count) orders")
        
        try! dataStore.setOrderSummaries(orderSummaries)
        try! dataStore.save()
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
    
    
    public var orderDetails: [OrderDetails] {
        
        dataStore.orderDetails
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderDetails.first { $0.id == orderId }
    }
    
    
    public func loadOrderDetails(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order details \(orderId)")
        
        let blOrder = await brickLinkAPIClient.fetchDetails(forOrderWithId: orderId)
        let order = OrderDetails(fromBl: blOrder)
        
        try! dataStore.setOrderDetail(order)
        try! dataStore.save()
    }
    
    
    public func loadOrderDetailsIfMissing(forOrderWithId orderId: String) async {
        
        if !orderDetails.contains(where: { $0.id == orderId }) {
            
            await loadOrderDetails(forOrderWithId: orderId)
        }
    }
    
    
    public func reloadOrderDetails(forOrderWithId orderId: String) async {
        
        if orderDetails.contains(where: { $0.id == orderId }) {
            
            await loadOrderDetails(forOrderWithId: orderId)
        }
    }
    
    
    // MARK: - Order status, Tracking no, Drive thru
    
    
    public func updateOrderStatus(orderId: OrderSummary.ID, status: OrderStatus) async {
        
        print("Update status \(status) for order \(orderId)")
        
        await brickLinkAPIClient.updateStatus(ofOrderWithId: orderId, to: status)
        
        await parallel([
            { await self.reloadOrderSummaries() },
            { await self.reloadOrderDetails(forOrderWithId: orderId) },
        ])
    }
    
    
    public func updateTrackingNo(forOrderWithId orderId: OrderSummary.ID, trackingNo: String) async {
        
        print("Update tracking no \(trackingNo) for order \(orderId)")
        
        await brickLinkAPIClient.updateTrackingNo(ofOrderWithId: orderId, to: trackingNo)
        
        await parallel([
            { await self.reloadOrderSummaries() },
            { await self.reloadOrderDetails(forOrderWithId: orderId) },
        ])
    }
    
    
    public func sendDriveThru(orderId: OrderSummary.ID) async {
        
        print("Send drive thru for order \(orderId)")
        
        await brickLinkAPIClient.sendDriveThru(forOrderWithId: orderId, mailMe: true)
        
        await parallel([
            { await self.reloadOrderSummaries() },
            { await self.reloadOrderDetails(forOrderWithId: orderId) },
        ])
    }
    
    
    // MARK: - Order items
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        (dataStore.orderItemsByOrderId[orderId] ?? []).reduce([], { $0 + $1 })
    }
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID, fromItemIds itemsIds: [OrderItem.ID]) -> [OrderItem] {
        
        let items = orderItems(forOrderWithId: orderId)
        
        return itemsIds.map { id in items.first { $0.id == id }! }
    }
    
    
    public func loadOrderItems(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order items \(orderId)")
        
        let blBatches = await brickLinkAPIClient.fetchItems(forOrderWithId: orderId)
        
        let batches = blBatches.map { blItems in
            blItems.map { OrderItem(fromBl: $0, orderId: orderId) }
        }
        
        print("loaded \(batches.count) batches with total \(batches.reduce(0){$0+$1.count}) items")
        
        try! dataStore.setOrderItems(batches, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func loadOrderItemsIfMissing(forOrderWithId orderId: String) async {
        
        if !dataStore.orderItemsByOrderId.keys.contains(where: { $0 == orderId }) {
            
            await loadOrderItems(forOrderWithId: orderId)
        }
    }
}



extension OrderSummary {
    
    
    init(fromBl bl: BrickLinkOrder) {
        self.init(
            id: "\(bl.orderId)",
            date: bl.dateOrdered,
            buyer: bl.buyerName,
            items: bl.totalCount,
            lots: bl.uniqueCount,
            
            subTotal: bl.cost.subtotal.floatValue,
            grandTotal: bl.cost.grandTotal.floatValue,
            costCurrencyCode: bl.cost.currencyCode,
            
            dispSubTotal: bl.dispCost.subtotal.floatValue,
            dispGrandTotal: bl.dispCost.grandTotal.floatValue,
            dispCostCurrencyCode: bl.dispCost.currencyCode,
            
            status: OrderStatus(rawValue: bl.status)!,
            dateStatusChanged: bl.dateStatusChanged,
            
            paymentStatus: PaymentStatus(rawValue: bl.payment.status)!
        )
    }
}



extension OrderDetails {
    
    
    init(fromBl bl: BrickLinkOrder) {
        
        self.init(
            id: "\(bl.orderId)",
            date: bl.dateOrdered,
            buyer: bl.buyerName,
            items: bl.totalCount,
            lots: bl.uniqueCount,

            subTotal: bl.cost.subtotal.floatValue,
            grandTotal: bl.cost.grandTotal.floatValue,
            shippingCost: bl.cost.shipping!.floatValue,
            costCurrencyCode: bl.cost.currencyCode,

            dispSubTotal: bl.dispCost.subtotal.floatValue,
            dispGrandTotal: bl.dispCost.grandTotal.floatValue,
            dispShippingCost: bl.dispCost.shipping!.floatValue,
            dispCostCurrencyCode: bl.dispCost.currencyCode,

            status: OrderStatus(rawValue: bl.status)!,
            driveThruSent: bl.driveThruSent!,
            trackingNo: bl.shipping!.trackingNo,
            totalWeight: bl.totalWeight!.floatValue,

            shippingMethodId: bl.shipping!.methodId,
            shippingMethodName: bl.shipping!.method,
            shippingAddress: bl.shipping!.address.full.htmlUnescape(),
            shippingAddressCountryCode: bl.shipping!.address.countryCode,
            shippingAddressName: bl.shipping!.address.name.full,

            remarks: bl.remarks
        )
    }
}



extension OrderItem {
    
    
    init(fromBl bl: BrickLinkOrderItem, orderId: String) {
        
        self.inventoryId = "\(bl.inventoryId)"
        self.orderId = orderId
        self.condition = bl.newOrUsed
        self.colorId = "\(bl.colorId)"
        self.colorName = bl.colorName
        self.ref = bl.item.no
        self.name = bl.item.name.htmlUnescape()
        self.type = bl.item.type
        self.location = bl.remarks ?? ""
        self.comment = (bl.description ?? "").htmlUnescape()
        self.quantity = "\(bl.quantity)"
        self.unitPrice = bl.unitPrice.floatValue
        self.unitPriceFinal = bl.unitPriceFinal.floatValue
    }
}
