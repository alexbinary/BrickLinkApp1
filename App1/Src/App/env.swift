
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
