
import Foundation



typealias Env = (
    
    catalog: Catalog,
    
    stores: (
        
        inventory: InventoryUserStore,
        upload: UploadUserStore,

        order: OrderUserStore,
        picking: PickingUserStore,
        shipping: ShippingUserStore,
        tracking: TrackingUserStore,
        feedback: FeedbackUserStore,
        refund: RefundUserStore,

        transaction: TransactionUserStore,
        result: ResultUserStore
    )
)



func createEnv() -> Env {
    
    let fileDataAccess: FileDataAccess = {
        let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
        return FileDataAccess(dataFileUrl: URL(fileURLWithPath: path))
    }()
    
    // Core controllers
    
    let catalog = Catalog(fileDataAccess)
    
    let inventoryCoreController = InventoryCoreController(fileDataAccess)
    let uploadCoreController = UploadCoreController(fileDataAccess)
    
    let orderCoreController = OrderCoreController(fileDataAccess)
    let pickingCoreController = PickingCoreController(fileDataAccess)
    let shippingCoreController = ShippingCoreController(fileDataAccess)
    let trackingCoreController = TrackingCoreController(fileDataAccess)
    let feedbackCoreController = FeedbackCoreController(fileDataAccess)
    let refundCoreController = RefundCoreController(fileDataAccess)
    let transactionCoreController = TransactionCoreController(fileDataAccess)
    
    let trackingMiddleController = TrackingMiddleController(trackingCoreController, orderCoreController)
    let feedbackMiddleController = FeedbackMiddleController(orderCoreController, feedbackCoreController)
    
    let pickingProgressCoreController = PickingProgressCoreController(orderCoreController, pickingCoreController)
    let orderChecklistCoreController = OrderChecklistCoreController(orderCoreController, pickingCoreController, shippingCoreController, feedbackCoreController, transactionCoreController, trackingMiddleController, pickingProgressCoreController)
    let orderMacroStatusCoreController = OrderMacroStatusCoreController(orderCoreController, orderChecklistCoreController)
    let stockCoreController = StockCoreController(orderCoreController, pickingCoreController, inventoryCoreController, orderMacroStatusCoreController)
    
    // User Stores
    
    let inventoryUserStore = InventoryUserStore(inventoryCoreController, stockCoreController)
    let uploadUserStore = UploadUserStore(uploadCoreController, inventoryCoreController, catalog)
    
    let orderUserStore = OrderUserStore(orderCoreController, orderMacroStatusCoreController, orderChecklistCoreController, pickingProgressCoreController, trackingMiddleController, feedbackMiddleController, feedbackCoreController)
    let pickingUserStore = PickingUserStore(pickingCoreController, orderCoreController, pickingProgressCoreController)
    let shippingUserStore = ShippingUserStore(shippingCoreController, orderCoreController)
    let trackingUserStore = TrackingUserStore(trackingMiddleController)
    let feedbackUserStore = FeedbackUserStore(feedbackCoreController, feedbackMiddleController)
    let refundUserStore = RefundUserStore(refundCoreController)
    
    let transactionUserStore = TransactionUserStore(transactionCoreController)
    let resultUserStore = ResultUserStore(orderCoreController, shippingCoreController, refundCoreController, transactionCoreController)
    
    return (
        
        catalog: catalog,
        
        stores: (
            
            inventory: inventoryUserStore,
            upload: uploadUserStore,
            
            order: orderUserStore,
            picking: pickingUserStore,
            shipping: shippingUserStore,
            tracking: trackingUserStore,
            feedback: feedbackUserStore,
            refund: refundUserStore,
            
            transaction: transactionUserStore,
            result: resultUserStore
        )
    )
}
