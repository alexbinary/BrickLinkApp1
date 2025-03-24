
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
    
    let orderCoreController = OrderCoreController(fileDataAccess)
    let pickingCoreController = PickingCoreController(fileDataAccess)
    let shippingCoreController = ShippingCoreController(fileDataAccess)
    
    // Data accesss
    
    let trackingDataAccess = TrackingDataAccess(fileDataAccess)
    let feedbackDataAccess = FeedbackDataAccess(fileDataAccess)
    let refundDataAccess = RefundDataAccess(fileDataAccess)
    
    let transactionDataAccess = TransactionDataAccess(fileDataAccess)
    
    // Stores & Controllers
    
    let catalog = Catalog(fileDataAccess)
    
    let pickingProgressCoreController = PickingProgressCoreController(orderCoreController, pickingCoreController)
    let trackingStore = TrackingStore(orderCoreController, trackingDataAccess)
    let feedbackStore = FeedbackStore(feedbackDataAccess)
    
    let refundStore = RefundStore(refundDataAccess)
    
    let transactionStore = TransactionStore(transactionDataAccess)
    let resultStore = ResultStore(orderCoreController, shippingCoreController, refundDataAccess, transactionDataAccess)
    
    let orderChecklistCoreController = OrderChecklistCoreController(orderCoreController, pickingCoreController, shippingCoreController, feedbackDataAccess, transactionDataAccess, trackingStore, pickingProgressCoreController)
    
    let orderMacroStatusCoreController = OrderMacroStatusCoreController(orderCoreController, orderChecklistCoreController)
    
    let stockCoreController = StockCoreController(orderCoreController, pickingCoreController, inventoryCoreController, orderMacroStatusCoreController)
    
    let feedbackController = FeedbackController(orderCoreController, feedbackDataAccess)
    
    // User Stores
    
    let inventoryUserStore = InventoryUserStore(inventoryCoreController, stockCoreController)
    let uploadUserStore = UploadUserStore(uploadCoreController, inventoryCoreController, catalog)
    
    let orderUserStore = OrderUserStore(orderCoreController, orderMacroStatusCoreController, orderChecklistCoreController, pickingProgressCoreController, trackingStore, feedbackController, feedbackDataAccess)
    let pickingUserStore = PickingUserStore(pickingCoreController, orderCoreController, pickingProgressCoreController)
    let shippingUserStore = ShippingUserStore(shippingCoreController, orderCoreController)
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
