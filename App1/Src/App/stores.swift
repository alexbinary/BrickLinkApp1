
import Foundation



func createStores() -> (
        
        catalog: Catalog,
        inventory: InventoryStore,
        upload: UploadStore,
        stock: StockStore,

        order: OrderStore,
        picking: PickingStore,
        shipping: ShippingStore,
        tracking: TrackingStore,
        feedback: FeedbackStore,
        refund: RefundStore,

        transaction: TransactionStore,
        result: ResultStore,

        orderChecklist: OrderChecklistStore,
        orderAction: OrderActionStore,
        
        reload: ReloadController
        
) {
    
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
    
    // Stores
    
    let catalog = Catalog(fileDataAccess)
    let inventoryStore = InventoryStore(inventoryDataAccess)
    let uploadStore = UploadStore(uploadDataAccess, catalog, inventoryDataAccess)
    
    let pickingStore = PickingStore(orderDataAccess, pickingDataAccess)
    let shippingStore = ShippingStore(orderDataAccess, shippingDataAccess)
    let trackingStore = TrackingStore(orderDataAccess, trackingDataAccess)
    let feedbackStore = FeedbackStore(orderDataAccess, feedbackDataAccess)
    let refundStore = RefundStore(refundDataAccess)
    
    let transactionStore = TransactionStore(transactionDataAccess)
    let resultStore = ResultStore(orderDataAccess, shippingDataAccess, refundDataAccess, transactionDataAccess)
    
    let orderChecklistStore = OrderChecklistStore(orderDataAccess, pickingDataAccess, shippingDataAccess, feedbackDataAccess, transactionDataAccess, trackingStore, pickingStore)
    
    let orderStore = OrderStore(orderDataAccess, orderChecklistStore)
    
    let stockStore = StockStore(orderDataAccess, pickingDataAccess, inventoryDataAccess, orderStore)
    let orderActionStore = OrderActionStore(orderDataAccess, orderStore, orderChecklistStore, feedbackStore)
    
    let reloadController = ReloadController(orderDataAccess, feedbackDataAccess, orderStore, trackingStore)
    
    return (
        
        catalog: catalog,
        inventory: inventoryStore,
        upload: uploadStore,
        stock: stockStore,
        
        order: orderStore,
        picking: pickingStore,
        shipping: shippingStore,
        tracking: trackingStore,
        feedback: feedbackStore,
        refund: refundStore,
        
        transaction: transactionStore,
        result: resultStore,
        
        orderChecklist: orderChecklistStore,
        orderAction: orderActionStore,
        
        reload: reloadController
    )
}
