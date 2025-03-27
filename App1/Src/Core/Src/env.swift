
import Foundation



public typealias Env = (
    
    catalog: Catalog,
    
    stores: (
        
        inventory: InventoryStore,
        upload: UploadStore,

        order: OrderStore,
        picking: PickingStore,
        shipping: ShippingStore,
        tracking: TrackingStore,
        feedback: FeedbackStore,
        refund: RefundStore,

        transaction: TransactionStore,
        result: ResultStore
    )
)



@MainActor
public func createEnv(brickLinkCredentials: BrickLinkAPICredentials, debug: Debug) -> Env {
    
    let dataStore: DataStore = {
        let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
        return DataStore(dataFileUrl: URL(fileURLWithPath: path))
    }()
    
    let brickLinkAPIClient = BrickLinkAPIClient(withCredentials: brickLinkCredentials, debug: debug)
    
    // Core controllers
    
    let catalog = Catalog(dataStore, brickLinkAPIClient)
    
    let inventoryCoreController = InventoryCoreController(dataStore, brickLinkAPIClient)
    let uploadCoreController = UploadCoreController(dataStore)
    
    let orderCoreController = OrderCoreController(dataStore, brickLinkAPIClient)
    let pickingCoreController = PickingCoreController(dataStore)
    let shippingCoreController = ShippingCoreController(dataStore)
    let trackingCoreController = TrackingCoreController(dataStore, debug)
    let feedbackCoreController = FeedbackCoreController(dataStore, brickLinkAPIClient)
    let refundCoreController = RefundCoreController(dataStore)
    let transactionCoreController = TransactionCoreController(dataStore)
    
    let trackingMiddleController = TrackingMiddleController(trackingCoreController, orderCoreController)
    let feedbackPostController = FeedbackPostController(feedbackCoreController, orderCoreController)
    
    let pickingProgressCoreController = PickingProgressCoreController(pickingCoreController, orderCoreController)
    let orderChecklistCoreController = OrderChecklistCoreController(orderCoreController, pickingCoreController, shippingCoreController, feedbackCoreController, transactionCoreController, trackingMiddleController, pickingProgressCoreController)
    let orderMacroStatusCoreController = OrderMacroStatusCoreController(orderCoreController, orderChecklistCoreController)
    let stockCoreController = StockCoreController(inventoryCoreController, pickingCoreController, orderCoreController, orderMacroStatusCoreController)
    
    // User Stores
    
    let inventoryStore = InventoryStore(inventoryCoreController, stockCoreController)
    let uploadStore = UploadStore(uploadCoreController, inventoryCoreController, catalog)
    
    let orderStore = OrderStore(orderCoreController, orderChecklistCoreController, orderMacroStatusCoreController, pickingProgressCoreController, trackingMiddleController, feedbackCoreController, feedbackPostController)
    let pickingStore = PickingStore(pickingCoreController, pickingProgressCoreController, orderCoreController)
    let shippingStore = ShippingStore(shippingCoreController, orderCoreController)
    let trackingStore = TrackingStore(trackingMiddleController)
    let feedbackStore = FeedbackStore(feedbackCoreController, feedbackPostController)
    let refundStore = RefundStore(refundCoreController)
    
    let transactionStore = TransactionStore(transactionCoreController)
    let resultStore = ResultStore(orderCoreController, shippingCoreController, refundCoreController, transactionCoreController)
    
    return (
        
        catalog: catalog,
        
        stores: (
            
            inventory: inventoryStore,
            upload: uploadStore,
            
            order: orderStore,
            picking: pickingStore,
            shipping: shippingStore,
            tracking: trackingStore,
            feedback: feedbackStore,
            refund: refundStore,
            
            transaction: transactionStore,
            result: resultStore
        )
    )
}
