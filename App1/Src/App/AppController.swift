
import SwiftUI


class AppController: ObservableObject {
    
    
    private let dataStore: DataStore = {
        
        let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
        return DataStore(dataFileUrl: URL(fileURLWithPath: path))
    }()
    
    private let blCredentials = Secrets.brickLinkAPICredentials
    
    let uploadStore: UploadStore
    let catalogStore: CatalogStore
    let inventoryStore: InventoryStore
    
    let transactionStore: TransactionStore
    let refundStore: RefundStore
    
    let orderStore: OrderStore
    let pickingStore: PickingStore
    let shippingStore: ShippingStore
    let trackingStore: TrackingStore
    let feedbackStore: FeedbackStore
    
    let uploadController: UploadController
    let pickingController: PickingController
    let shippingController: ShippingController
    let trackingController: TrackingController
    let feedbackController: FeedbackController
    
    let orderChecklistController: OrderChecklistController
    let resultController: ResultController
    
    let orderController: OrderController
    let stockController: StockController
    let reloadController: ReloadController
    let orderActionController: OrderActionController
    
    
    init() {
        
        uploadStore = UploadStore(dataStore: dataStore)
        catalogStore = CatalogStore(dataStore: dataStore, blCredentials: blCredentials)
        inventoryStore = InventoryStore(dataStore: dataStore, blCredentials: blCredentials)
        
        transactionStore = TransactionStore(dataStore: dataStore)
        refundStore = RefundStore(dataStore: dataStore)
        
        orderStore = OrderStore(dataStore: dataStore, blCredentials: blCredentials)
        pickingStore = PickingStore(dataStore: dataStore)
        shippingStore = ShippingStore(dataStore: dataStore)
        trackingStore = TrackingStore(dataStore: dataStore)
        feedbackStore = FeedbackStore(dataStore: dataStore, blCredentials: blCredentials)
        
        uploadController = UploadController(uploadStore: uploadStore, catalogStore: catalogStore, inventoryStore: inventoryStore)
        pickingController = PickingController(orderStore: orderStore, pickingStore: pickingStore)
        shippingController = ShippingController(orderStore: orderStore)
        trackingController = TrackingController(orderStore: orderStore, trackingStore: trackingStore)
        feedbackController = FeedbackController(orderStore: orderStore, feedbackStore: feedbackStore)
        
        orderChecklistController = OrderChecklistController(orderStore: orderStore, pickingStore: pickingStore, shippingStore: shippingStore, feedbackStore: feedbackStore, transactionStore: transactionStore)
        resultController = ResultController(orderStore: orderStore, shippingStore: shippingStore, refundStore: refundStore, transactionStore: transactionStore)
        
        orderController = OrderController(orderStore: orderStore, orderChecklistController: orderChecklistController)
        stockController = StockController(orderStore: orderStore, pickingStore: pickingStore, inventoryStore: inventoryStore, orderController: orderController)
        reloadController = ReloadController(orderStore: orderStore, feedbackStore: feedbackStore, orderController: orderController, trackingController: trackingController)
        orderActionController = OrderActionController(orderStore: orderStore, orderController: orderController, orderChecklistController: orderChecklistController, feedbackController: feedbackController)
        
        Task {
            await parallel([
                { await self.loadColors() },
                { await self.loadInventories() },
                { await self.loadOrderSummaries() },
            ])
        }
    }
    
    
    private func loadColors() async {
        
        await catalogStore.loadColors()
    }
    
    
    private func loadOrderSummaries() async {
        
        await orderStore.loadOrderSummaries()
    }
    
    
    private func loadInventories() async {
        
        await inventoryStore.loadInventories()
    }
}
