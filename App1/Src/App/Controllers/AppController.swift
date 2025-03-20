
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
        
        let fileDataAccess: FileDataAccess = {
            let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
            return FileDataAccess(dataFileUrl: URL(fileURLWithPath: path))
        }()
        
        // Data accesss
        
        let catalogDataAccess = CatalogDataAccess(fileDataAccess)
        let inventoryDataAccess = InventoryDataAccess(fileDataAccess)
        let uploadDataAccess = UploadDataAccess(fileDataAccess)
        
        let orderDataAccess = OrderDataAccess(fileDataAccess)
        let pickingDataAccess = PickingDataAccess(fileDataAccess)
        let shippingDataAccess = ShippingDataAccess(fileDataAccess)
        let trackingDataAccess = TrackingDataAccess(fileDataAccess)
        let feedbackDataAccess = FeedbackDataAccess(fileDataAccess)
        let refundDataAccess = RefundDataAccess(fileDataAccess)
        
        let transactionDataAccess = TransactionDataAccess(fileDataAccess)
        
        // Controllers
        
        let catalogController = CatalogController(catalogDataAccess)
        let inventoryController = InventoryController(inventoryDataAccess)
        let uploadController = UploadController(uploadDataAccess, catalogDataAccess, inventoryDataAccess)
        
        let pickingController = PickingController(orderDataAccess, pickingDataAccess)
        let shippingController = ShippingController(orderDataAccess, shippingDataAccess)
        let trackingController = TrackingController(orderDataAccess, trackingDataAccess)
        let feedbackController = FeedbackController(orderDataAccess, feedbackDataAccess)
        let refundController = RefundController(refundDataAccess)
        
        let transactionController = TransactionController(transactionDataAccess)
        let resultController = ResultController(orderDataAccess, shippingDataAccess, refundDataAccess, transactionDataAccess)
        
        let orderChecklistController = OrderChecklistController(orderDataAccess, pickingDataAccess, shippingDataAccess, feedbackDataAccess, transactionDataAccess, trackingController, pickingController)
        
        let orderController = OrderController(orderDataAccess, orderChecklistController)
        
        let stockController = StockController(orderDataAccess, pickingDataAccess, inventoryDataAccess, orderController)
        let reloadController = ReloadController(orderDataAccess, feedbackDataAccess, orderController, trackingController)
        let orderActionController = OrderActionController(orderDataAccess, orderController, orderChecklistController, feedbackController)
        
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
