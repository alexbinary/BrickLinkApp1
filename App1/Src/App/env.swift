
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
    
    let inventoryCoreController = InventoryCoreController(fileDataAccess)
    let uploadCoreController = UploadCoreController(fileDataAccess)
    
    // Data accesss
    
    let orderDataAccess = OrderDataAccess(fileDataAccess)
    let pickingDataAccess = PickingDataAccess(fileDataAccess)
    let shippingDataAccess = ShippingDataAccess(fileDataAccess)
    let trackingDataAccess = TrackingDataAccess(fileDataAccess)
    let feedbackDataAccess = FeedbackDataAccess(fileDataAccess)
    let refundDataAccess = RefundDataAccess(fileDataAccess)
    
    let transactionDataAccess = TransactionDataAccess(fileDataAccess)
    
    // Stores & Controllers
    
    let catalog = Catalog(fileDataAccess)
    
    let pickingStore = PickingStore(orderDataAccess, pickingDataAccess)
    let shippingStore = ShippingStore(orderDataAccess, shippingDataAccess)
    let trackingStore = TrackingStore(orderDataAccess, trackingDataAccess)
    let feedbackStore = FeedbackStore(feedbackDataAccess)
    
    let refundStore = RefundStore(refundDataAccess)
    
    let transactionStore = TransactionStore(transactionDataAccess)
    let resultStore = ResultStore(orderDataAccess, shippingDataAccess, refundDataAccess, transactionDataAccess)
    
    let orderChecklistStore = OrderChecklistStore(orderDataAccess, pickingDataAccess, shippingDataAccess, feedbackDataAccess, transactionDataAccess, trackingStore, pickingStore)
    
    let orderStore = OrderStore(orderDataAccess, orderChecklistStore)
    
    let stockCoreController = StockCoreController(orderDataAccess, pickingDataAccess, inventoryCoreController, orderStore)
    
    let feedbackController = FeedbackController(orderDataAccess, feedbackDataAccess)
    let orderActionStore = OrderActionStore(orderDataAccess, orderStore, orderChecklistStore, feedbackController)
    
    //
    
    let reloadController = ReloadController(orderDataAccess, feedbackDataAccess, orderStore, trackingStore)
    
    // User Stores
    
    let inventoryUserStore = InventoryUserStore(inventoryCoreController, stockCoreController)
    let uploadUserStore = UploadUserStore(uploadCoreController, inventoryCoreController, catalog)
    
    let orderUserStore = OrderUserStore(orderDataAccess, orderStore, orderChecklistStore, orderActionStore, reloadController)
    let pickingUserStore = PickingUserStore(pickingStore)
    let shippingUserStore = ShippingUserStore(shippingStore)
    let trackingUserStore = TrackingUserStore(trackingStore)
    let feedbackUserStore = FeedbackUserStore(feedbackStore, feedbackController)
    let refundUserStore = RefundUserStore(refundStore)
    
    let transactionUserStore = TransactionUserStore(transactionStore)
    let resultUserStore = ResultUserStore(resultStore: resultStore)
    
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
