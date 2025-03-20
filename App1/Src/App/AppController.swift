
import Foundation



enum AppController {

    
    static func createControllers() -> (
        
        uploadStore: UploadStore,
        catalogStore: CatalogStore,
        inventoryStore: InventoryStore,

        transactionController: TransactionController,
        refundStore: RefundStore,

        orderStore: OrderStore,
        pickingStore: PickingStore,
        trackingStore: TrackingStore,

        uploadController: UploadController,
        pickingController: PickingController,
        shippingController: ShippingController,
        trackingController: TrackingController,
        feedbackController: FeedbackController,

        orderChecklistController: OrderChecklistController,
        resultController: ResultController,

        orderController: OrderController,
        stockController: StockController,
        reloadController: ReloadController,
        orderActionController: OrderActionController
        
    ) {
        
        let dataStore: DataStore = {
            let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
            return DataStore(dataFileUrl: URL(fileURLWithPath: path))
        }()
        
        let uploadStore = UploadStore(dataStore)
        let catalogStore = CatalogStore(dataStore)
        let inventoryStore = InventoryStore(dataStore)
        
        let transactionStore = TransactionStore(dataStore)
        let transactionController = TransactionController(transactionStore)
        let refundStore = RefundStore(dataStore)
        
        let orderStore = OrderStore(dataStore)
        let pickingStore = PickingStore(dataStore)
        let shippingStore = ShippingStore(dataStore)
        let trackingStore = TrackingStore(dataStore)
        let feedbackStore = FeedbackStore(dataStore)
        
        let uploadController = UploadController(uploadStore, catalogStore, inventoryStore)
        let pickingController = PickingController(orderStore, pickingStore)
        let shippingController = ShippingController(orderStore, shippingStore)
        let trackingController = TrackingController(orderStore, trackingStore)
        let feedbackController = FeedbackController(orderStore, feedbackStore)
        
        let orderChecklistController = OrderChecklistController(orderStore, pickingStore, shippingStore, feedbackStore, transactionStore, trackingController, pickingController)
        let resultController = ResultController(orderStore, shippingStore, refundStore, transactionStore)
        
        let orderController = OrderController(orderStore, orderChecklistController)
        let stockController = StockController(orderStore, pickingStore, inventoryStore, orderController)
        let reloadController = ReloadController(orderStore, feedbackStore, orderController, trackingController)
        let orderActionController = OrderActionController(orderStore, orderController, orderChecklistController, feedbackController)
        
        return (
            
            uploadStore: uploadStore,
            catalogStore: catalogStore,
            inventoryStore: inventoryStore,

            transactionController: transactionController,
            refundStore: refundStore,

            orderStore: orderStore,
            pickingStore: pickingStore,
            trackingStore: trackingStore,

            uploadController: uploadController,
            pickingController: pickingController,
            shippingController: shippingController,
            trackingController: trackingController,
            feedbackController: feedbackController,

            orderChecklistController: orderChecklistController,
            resultController: resultController,

            orderController: orderController,
            stockController: stockController,
            reloadController: reloadController,
            orderActionController: orderActionController
        )
    }
}
