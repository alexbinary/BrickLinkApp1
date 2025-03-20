
import Foundation



enum AppController {

    
    static func createControllers() -> (
        
        catalog: CatalogController,
        inventory: InventoryController,
        upload: UploadController,
        stock: StockController,

        order: OrderController,
        picking: PickingController,
        shipping: ShippingController,
        tracking: TrackingController,
        feedback: FeedbackController,
        refund: RefundController,

        transaction: TransactionController,
        result: ResultController,

        reload: ReloadController,

        orderChecklist: OrderChecklistController,
        orderAction: OrderActionController
        
    ) {
        
        let dataStore: DataStore = {
            let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
            return DataStore(dataFileUrl: URL(fileURLWithPath: path))
        }()
        
        // Stores
        
        let catalogStore = CatalogStore(dataStore)
        let inventoryStore = InventoryStore(dataStore)
        let uploadStore = UploadStore(dataStore)
        
        let orderStore = OrderStore(dataStore)
        let pickingStore = PickingStore(dataStore)
        let shippingStore = ShippingStore(dataStore)
        let trackingStore = TrackingStore(dataStore)
        let feedbackStore = FeedbackStore(dataStore)
        let refundStore = RefundStore(dataStore)
        
        let transactionStore = TransactionStore(dataStore)
        
        // Controllers
        
        let catalogController = CatalogController(catalogStore)
        let inventoryController = InventoryController(inventoryStore)
        let uploadController = UploadController(uploadStore, catalogStore, inventoryStore)
        
        let pickingController = PickingController(orderStore, pickingStore)
        let shippingController = ShippingController(orderStore, shippingStore)
        let trackingController = TrackingController(orderStore, trackingStore)
        let feedbackController = FeedbackController(orderStore, feedbackStore)
        let refundController = RefundController(refundStore)
        
        let transactionController = TransactionController(transactionStore)
        let resultController = ResultController(orderStore, shippingStore, refundStore, transactionStore)
        
        let orderChecklistController = OrderChecklistController(orderStore, pickingStore, shippingStore, feedbackStore, transactionStore, trackingController, pickingController)
        
        let orderController = OrderController(orderStore, orderChecklistController)
        
        let stockController = StockController(orderStore, pickingStore, inventoryStore, orderController)
        let reloadController = ReloadController(orderStore, feedbackStore, orderController, trackingController)
        let orderActionController = OrderActionController(orderStore, orderController, orderChecklistController, feedbackController)
        
        return (
            
            catalog: catalogController,
            inventory: inventoryController,
            upload: uploadController,
            stock: stockController,

            order: orderController,
            picking: pickingController,
            shipping: shippingController,
            tracking: trackingController,
            feedback: feedbackController,
            refund: refundController,

            transaction: transactionController,
            result: resultController,

            reload: reloadController,

            orderChecklist: orderChecklistController,
            orderAction: orderActionController
        )
    }
}
