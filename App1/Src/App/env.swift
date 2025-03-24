
import Foundation



typealias Env = (
    
    catalog: Catalog,
    
    stores: (
        
        inventory: InventoryUserStore,
        upload: UploadUserStore,
        stock: StockStore,

        order: OrderUserStore,
        picking: PickingUserStore,
        shipping: ShippingUserStore,
        tracking: TrackingUserStore,
        feedback: FeedbackUserStore,
        refund: RefundUserStore,

        transaction: TransactionUserStore,
        result: ResultUserStore
    ),
    
    controllers: (
        
        inventory: InventoryController,
        feedback: FeedbackUserController
    )
)



func createEnv() -> Env {
    
    let fileDataAccess: FileDataAccess = {
        let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
        return FileDataAccess(dataFileUrl: URL(fileURLWithPath: path))
    }()
    
    // Data accesss
    
    let inventoryDataAccess = InventoryDataAccess(fileDataAccess)
    let uploadDataAccess = UploadDataAccess(fileDataAccess)
    
    let orderDataAccess = OrderDataAccess(fileDataAccess)
    let pickingDataAccess = PickingDataAccess(fileDataAccess)
    let shippingDataAccess = ShippingDataAccess(fileDataAccess)
    let trackingDataAccess = TrackingDataAccess(fileDataAccess)
    let feedbackDataAccess = FeedbackDataAccess(fileDataAccess)
    let refundDataAccess = RefundDataAccess(fileDataAccess)
    
    let transactionDataAccess = TransactionDataAccess(fileDataAccess)
    
    // Stores & Controllers
    
    let catalog = Catalog(fileDataAccess)
    let inventoryStore = InventoryStore(inventoryDataAccess)
    let uploadStore = UploadStore(uploadDataAccess, catalog, inventoryDataAccess)
    
    let pickingStore = PickingStore(orderDataAccess, pickingDataAccess)
    let shippingStore = ShippingStore(orderDataAccess, shippingDataAccess)
    let trackingStore = TrackingStore(orderDataAccess, trackingDataAccess)
    let feedbackStore = FeedbackStore(feedbackDataAccess)
    
    let refundStore = RefundStore(refundDataAccess)
    
    let transactionStore = TransactionStore(transactionDataAccess)
    let resultStore = ResultStore(orderDataAccess, shippingDataAccess, refundDataAccess, transactionDataAccess)
    
    let orderChecklistStore = OrderChecklistStore(orderDataAccess, pickingDataAccess, shippingDataAccess, feedbackDataAccess, transactionDataAccess, trackingStore, pickingStore)
    
    let orderStore = OrderStore(orderDataAccess, orderChecklistStore)
    
    let stockStore = StockStore(orderDataAccess, pickingDataAccess, inventoryDataAccess, orderStore)
    
    let feedbackController = FeedbackController(orderDataAccess, feedbackDataAccess)
    let orderActionStore = OrderActionStore(orderDataAccess, orderStore, orderChecklistStore, feedbackController)
    
    //
    
    let inventoryController = InventoryController(inventoryDataAccess)
    let reloadController = ReloadController(orderDataAccess, feedbackDataAccess, orderStore, trackingStore)
    
    // User Stores
    
    let inventoryUserStore = InventoryUserStore(inventoryStore, inventoryController)
    let uploadUserStore = UploadUserStore(uploadStore)
    
    let orderUserStore = OrderUserStore(orderDataAccess, orderStore, orderChecklistStore, orderActionStore, reloadController)
    let pickingUserStore = PickingUserStore(pickingStore)
    let shippingUserStore = ShippingUserStore(shippingStore)
    let trackingUserStore = TrackingUserStore(trackingStore)
    let feedbackUserStore = FeedbackUserStore(feedbackStore)
    let refundUserStore = RefundUserStore(refundStore)
    
    let transactionUserStore = TransactionUserStore(transactionStore)
    let resultUserStore = ResultUserStore(resultStore: resultStore)
    
    // User Controllers
    
    let feedbackUserController = FeedbackUserController(orderDataAccess, feedbackDataAccess)
    
    return (
        
        catalog: catalog,
        
        stores: (
            
            inventory: inventoryUserStore,
            upload: uploadUserStore,
            stock: stockStore,
            
            order: orderUserStore,
            picking: pickingUserStore,
            shipping: shippingUserStore,
            tracking: trackingUserStore,
            feedback: feedbackUserStore,
            refund: refundUserStore,
            
            transaction: transactionUserStore,
            result: resultUserStore
        ),
        
        controllers: (
            
            inventory: inventoryController,
            feedback: feedbackUserController
        )
    )
}
