
import Foundation



@MainActor
class OrderCoreController {
    
    
    private let dataStore: DataStore
    private let brickLinkAPIClient: BrickLinkAPIClient
    
    
    init(_ dataStore: DataStore, _ brickLinkAPIClient: BrickLinkAPIClient) {
     
        self.dataStore = dataStore
        self.brickLinkAPIClient = brickLinkAPIClient
    }
    
    
    // MARK: - Order summaries
    
    
    var orders: [Order] {
        
        dataStore.orderSummaries
    }
    
    
    func order(withId orderId: Order.ID) -> Order? {
        
        orders.first { $0.id == orderId }
    }
    
    
    func loadOrders() async {
        
        print("Loading orders")
        
        let blOrders = await brickLinkAPIClient.fetchOrderSummaries()
        let orderSummaries = blOrders.map { Order(fromBl: $0) }.sorted { $0.date > $1.date }
        
        print("loaded \(orderSummaries.count) orders")
        
        try! dataStore.setOrderSummaries(orderSummaries)
        try! dataStore.save()
    }
    
    
    func loadOrdersIfMissing() async {
        
        if orders.isEmpty {
        
            await loadOrders()
        }
    }
    
    
    func reloadOrders() async {
        
        if !orders.isEmpty {
        
            await loadOrders()
        }
    }
    
    
    // MARK: - Orders details
    
    
    var orderDetails: [OrderDetails] {
        
        dataStore.orderDetails
    }
    
    
    func orderDetails(for order: Order) -> OrderDetails? {
        
        orderDetails.first { $0.id == order.id }
    }
    
    
    func loadOrderDetails(for order: Order) async {
        
        print("Loading order details \(order.id)")
        
        let blOrder = await brickLinkAPIClient.fetchOrderDetails(orderId: order.id)
        let orderDetails = OrderDetails(fromBl: blOrder)
        
        try! dataStore.setOrderDetail(orderDetails)
        try! dataStore.save()
    }
    
    
    func loadOrderDetailsIfMissing(for order: Order) async {
        
        if !orderDetails.contains(where: { $0.id == order.id }) {
            
            await loadOrderDetails(for: order)
        }
    }
    
    
    func reloadOrderDetails(for order: Order) async {
        
        if orderDetails.contains(where: { $0.id == order.id }) {
            
            await loadOrderDetails(for: order)
        }
    }
    
    
    // MARK: - Order status, Tracking no, Drive thru
    
    
    func updateOrderStatus(_ order: Order, status: OrderStatus) async {
        
        print("Update status \(status) for order \(order.id)")
        
        await brickLinkAPIClient.updateOrderStatus(orderId: order.id, status: status)
        
        await parallel([
            { await self.reloadOrders() },
            { await self.reloadOrderDetails(for: order) },
        ])
    }
    
    
    func updateTrackingNo(for order: Order, trackingNo: String) async {
        
        print("Update tracking no \(trackingNo) for order \(order.id)")
        
        await brickLinkAPIClient.updateTrackingNo(orderId: order.id, trackingNo: trackingNo)
        
        await parallel([
            { await self.reloadOrders() },
            { await self.reloadOrderDetails(for: order) },
        ])
    }
    
    
    func sendDriveThru(for order: Order) async {
        
        print("Send drive thru for order \(order.id)")
        
        await brickLinkAPIClient.sendDriveThru(orderId: order.id, mailMe: true)
        
        await parallel([
            { await self.reloadOrders() },
            { await self.reloadOrderDetails(for: order) },
        ])
    }
    
    
    // MARK: - Order items
    
    
    func orderItems(for order: Order) -> [OrderItem] {
        
        (dataStore.orderItemsByOrderId[order.id] ?? []).reduce([], { $0 + $1 })
    }
    
    
    func orderItems(for order: Order, fromItemIds itemsIds: [OrderItem.ID]) -> [OrderItem] {
        
        let items = orderItems(for: order)
        
        return itemsIds.map { id in items.first { $0.id == id }! }
    }
    
    
    func loadOrderItems(for order: Order) async {
        
        print("Loading order items \(order.id)")
        
        let blBatches = await brickLinkAPIClient.fetchOrderItems(orderId: order.id)
        
        let batches = blBatches.map { blItems in
            blItems.map { OrderItem(fromBl: $0, orderId: order.id) }
        }
        
        print("loaded \(batches.count) batches with total \(batches.reduce(0){$0+$1.count}) items")
        
        try! dataStore.setOrderItems(batches, forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    func loadOrderItemsIfMissing(for order: Order) async {
        
        if !dataStore.orderItemsByOrderId.keys.contains(where: { $0 == order.id }) {
            
            await loadOrderItems(for: order)
        }
    }
}



extension Order {
    
    
    init(fromBl bl: BrickLinkOrderSummary) {
        self.init(
            id: "\(bl.orderId)",
            date: bl.dateOrdered,
            dateStatusChanged: bl.dateStatusChanged,
            buyer: bl.buyerName,
            status: OrderStatus(rawValue: bl.status)!,
            
            items: bl.totalCount,
            lots: bl.uniqueCount,
            
            paymentStatus: PaymentStatus(rawValue: bl.payment.status)!,
            
            subTotal: bl.cost.subtotal.floatValue,
            grandTotal: bl.cost.grandTotal.floatValue,
            costCurrencyCode: bl.cost.currencyCode,
            
            dispSubTotal: bl.dispCost.subtotal.floatValue,
            dispGrandTotal: bl.dispCost.grandTotal.floatValue,
            dispCostCurrencyCode: bl.dispCost.currencyCode
        )
    }
}



extension OrderDetails {
    
    
    init(fromBl bl: BrickLinkOrderDetails) {
        
        self.init(
            id: "\(bl.orderId)",
            date: bl.dateOrdered,
            dateStatusChanged: bl.dateStatusChanged,
            buyer: bl.buyerName,
            status: OrderStatus(rawValue: bl.status)!,
            remarks: bl.remarks,
            
            items: bl.totalCount,
            lots: bl.uniqueCount,
            totalWeight: bl.totalWeight!.floatValue,
            driveThruSent: bl.driveThruSent!,
            trackingNo: bl.shipping!.trackingNo,
            
            paymentStatus: PaymentStatus(rawValue: bl.payment.status)!,
            
            shippingMethodId: bl.shipping!.methodId,
            shippingMethodName: bl.shipping!.method,
            shippingAddress: bl.shipping!.address.full.htmlUnescape(),
            shippingAddressCountryCode: bl.shipping!.address.countryCode,
            shippingAddressName: bl.shipping!.address.name.full,
            
            subTotal: bl.cost.subtotal.floatValue,
            grandTotal: bl.cost.grandTotal.floatValue,
            shippingCost: bl.cost.shipping!.floatValue,
            costCurrencyCode: bl.cost.currencyCode,

            dispSubTotal: bl.dispCost.subtotal.floatValue,
            dispGrandTotal: bl.dispCost.grandTotal.floatValue,
            dispShippingCost: bl.dispCost.shipping!.floatValue,
            dispCostCurrencyCode: bl.dispCost.currencyCode
        )
    }
}



extension OrderItem {
    
    
    init(fromBl bl: BrickLinkOrderItem, orderId: String) {
        self.init(
            inventoryId: "\(bl.inventoryId)",
            orderId: orderId,
            condition: bl.newOrUsed,
            colorId: "\(bl.colorId)",
            colorName: bl.colorName,
            ref: bl.item.no,
            name: bl.item.name.htmlUnescape(),
            type: ItemType(fromBl: bl.item.type),
            location: bl.remarks ?? "",
            comment: (bl.description ?? "").htmlUnescape(),
            quantity: "\(bl.quantity)",
            unitPrice: bl.unitPrice.floatValue,
            unitPriceFinal: bl.unitPriceFinal.floatValue
        )
    }
}



extension ItemType {
    
    
    init(fromBl bl: BrickLinkItemType) {
        switch bl {
        case .part: self = .part
        case .minifig: self = .minifig
        }
    }
}
