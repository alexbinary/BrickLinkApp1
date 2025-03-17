
import Foundation



@Observable
class OrderStore {
    
    
    private let dataStore: DataStore
    private let blCredentials: BrickLinkAPICredentials
    
    
    init(dataStore: DataStore, blCredentials: BrickLinkAPICredentials) {
        self.dataStore = dataStore
        self.blCredentials = blCredentials
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
        
        let blOrders = await BrickLinkAPIClient.fetchOrderSummaries(using: blCredentials)
           
        let orderSummaries = blOrders
            .map { OrderSummary(fromBl: $0) }
            .sorted { $0.date > $1.date }
        
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
        
        let blOrder = await BrickLinkAPIClient.fetchDetails(forOrderWithId: orderId, using: blCredentials)
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
        
        print("update status \(status) for order \(orderId)")
        
        await BrickLinkAPIClient.updateStatus(ofOrderWithId: orderId, to: status, using: blCredentials)
        
        await parallel([
            { await self.reloadOrderSummaries() },
            { await self.reloadOrderDetails(forOrderWithId: orderId) },
        ])
    }
    
    
    public func updateTrackingNo(forOrderWithId orderId: OrderSummary.ID, trackingNo: String) async {
        
        print("update tracking no \(trackingNo) for order \(orderId)")
        
        await BrickLinkAPIClient.updateTrackingNo(ofOrderWithId: orderId, to: trackingNo, using: blCredentials)
        
        await parallel([
            { await self.reloadOrderSummaries() },
            { await self.reloadOrderDetails(forOrderWithId: orderId) },
        ])
    }
    
    
    public func sendDriveThru(orderId: OrderSummary.ID) async {
        
        print("send drive thru for order \(orderId)")
        
        await BrickLinkAPIClient.sendDriveThru(forOrderWithId: orderId, using: blCredentials, mailMe: true)
        
        await parallel([
            { await self.reloadOrderSummaries() },
            { await self.reloadOrderDetails(forOrderWithId: orderId) },
        ])
    }
}
