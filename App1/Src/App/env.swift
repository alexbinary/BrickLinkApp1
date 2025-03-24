
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
    
    let dataStore: DataStore = {
        let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
        return DataStore(dataFileUrl: URL(fileURLWithPath: path))
    }()
    
    // Core controllers
    
    let catalog = Catalog(dataStore)
    
    let inventoryCoreController = InventoryCoreController(dataStore)
    let uploadCoreController = UploadCoreController(dataStore)
    
    let orderCoreController = OrderCoreController(dataStore)
    let pickingCoreController = PickingCoreController(dataStore)
    let shippingCoreController = ShippingCoreController(dataStore)
    let trackingCoreController = TrackingCoreController(dataStore)
    let feedbackCoreController = FeedbackCoreController(dataStore)
    let refundCoreController = RefundCoreController(dataStore)
    let transactionCoreController = TransactionCoreController(dataStore)
    
    let trackingMiddleController = TrackingMiddleController(trackingCoreController, orderCoreController)
    let feedbackPostController = FeedbackPostController(feedbackCoreController, orderCoreController)
    
    let pickingProgressCoreController = PickingProgressCoreController(pickingCoreController, orderCoreController)
    let orderChecklistCoreController = OrderChecklistCoreController(orderCoreController, pickingCoreController, shippingCoreController, feedbackCoreController, transactionCoreController, trackingMiddleController, pickingProgressCoreController)
    let orderMacroStatusCoreController = OrderMacroStatusCoreController(orderCoreController, orderChecklistCoreController)
    let stockCoreController = StockCoreController(inventoryCoreController, pickingCoreController, orderCoreController, orderMacroStatusCoreController)
    
    // User Stores
    
    let inventoryUserStore = InventoryUserStore(inventoryCoreController, stockCoreController)
    let uploadUserStore = UploadUserStore(uploadCoreController, inventoryCoreController, catalog)
    
    let orderUserStore = OrderUserStore(orderCoreController, orderChecklistCoreController, orderMacroStatusCoreController, pickingProgressCoreController, trackingMiddleController, feedbackCoreController, feedbackPostController)
    let pickingUserStore = PickingUserStore(pickingCoreController, pickingProgressCoreController, orderCoreController)
    let shippingUserStore = ShippingUserStore(shippingCoreController, orderCoreController)
    let trackingUserStore = TrackingUserStore(trackingMiddleController)
    let feedbackUserStore = FeedbackUserStore(feedbackCoreController, feedbackPostController)
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
