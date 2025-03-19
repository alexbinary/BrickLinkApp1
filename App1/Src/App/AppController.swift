
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
        
        uploadStore = UploadStore(dataStore)
        catalogStore = CatalogStore(dataStore, blCredentials)
        inventoryStore = InventoryStore(dataStore, blCredentials)
        
        transactionStore = TransactionStore(dataStore)
        refundStore = RefundStore(dataStore)
        
        orderStore = OrderStore(dataStore, blCredentials)
        pickingStore = PickingStore(dataStore)
        shippingStore = ShippingStore(dataStore)
        trackingStore = TrackingStore(dataStore)
        feedbackStore = FeedbackStore(dataStore, blCredentials)
        
        uploadController = UploadController(uploadStore, catalogStore, inventoryStore)
        pickingController = PickingController(orderStore, pickingStore)
        shippingController = ShippingController(orderStore)
        trackingController = TrackingController(orderStore, trackingStore)
        feedbackController = FeedbackController(orderStore, feedbackStore)
        
        orderChecklistController = OrderChecklistController(orderStore, pickingStore, shippingStore, feedbackStore, transactionStore)
        resultController = ResultController(orderStore, shippingStore, refundStore, transactionStore)
        
        orderController = OrderController(orderStore, orderChecklistController)
        stockController = StockController(orderStore, pickingStore, inventoryStore, orderController)
        reloadController = ReloadController(orderStore, feedbackStore, orderController, trackingController)
        orderActionController = OrderActionController(orderStore, orderController, orderChecklistController, feedbackController)
    }
}
