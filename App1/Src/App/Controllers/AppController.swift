
import Foundation



enum AppController {

    
    static func createControllers() -> (
        
        catalogController: CatalogController,
        inventoryController: InventoryController,

        transactionController: TransactionController,
        refundController: RefundController,

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
        let catalogController = CatalogController(catalogStore)
        let inventoryStore = InventoryStore(dataStore)
        let inventoryController = InventoryController(inventoryStore)
        
        let transactionStore = TransactionStore(dataStore)
        let transactionController = TransactionController(transactionStore)
        let refundStore = RefundStore(dataStore)
        let refundController = RefundController(refundStore)
        
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
            
            catalogController: catalogController,
            inventoryController: inventoryController,

            transactionController: transactionController,
            refundController: refundController,

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
