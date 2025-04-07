
import Foundation



@MainActor
public class CoreController {
    
    
    public let catalog: Catalog
        
    public let inventoryStore: InventoryStore
    public let uploadStore: UploadStore
    
    public let orderStore: OrderStore
    public let pickingStore: PickingStore
    public let shippingStore: ShippingStore
    public let trackingStore: TrackingStore
    public let feedbackStore: FeedbackStore
    public let refundStore: RefundStore
    
    public let transactionStore: TransactionStore
    public let resultStore: ResultStore
    
    public let updateStore: UpdateStore
    
    
    public init(brickLinkCredentials: BrickLinkAPICredentials, debug: Debug) {
        
        let dataStore: DataStore = {
            let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
            return DataStore(dataFileUrl: URL(fileURLWithPath: path))
        }()
        
        let brickLinkAPIClient = BrickLinkAPIClient(withCredentials: brickLinkCredentials, debug: debug)
        let laPosteTrackingClient = LaPosteTrackingClient(debug)
        
        let updateController = UpdateController(dataStore, brickLinkAPIClient, laPosteTrackingClient)
        
        let inventoryCoreController = InventoryCoreController(dataStore, updateController, brickLinkAPIClient)
        let uploadCoreController = UploadCoreController(dataStore)
        
        let orderCoreController = OrderCoreController(dataStore, updateController)
        let pickingCoreController = PickingCoreController(dataStore)
        let shippingCoreController = ShippingCoreController(dataStore)
        let trackingCoreController = TrackingCoreController(dataStore, updateController)
        let feedbackCoreController = FeedbackCoreController(dataStore, updateController)
        let refundCoreController = RefundCoreController(dataStore)
        let transactionCoreController = TransactionCoreController(dataStore)
        
        let trackingMiddleController = TrackingMiddleController(trackingCoreController, orderCoreController)
        let feedbackPostController = FeedbackPostController(feedbackCoreController, orderCoreController)
        
        let pickingProgressCoreController = PickingProgressCoreController(pickingCoreController, orderCoreController)
        let orderChecklistCoreController = OrderChecklistCoreController(orderCoreController, pickingCoreController, shippingCoreController, feedbackCoreController, transactionCoreController, trackingMiddleController, pickingProgressCoreController)
        let orderMacroStatusCoreController = OrderMacroStatusCoreController(orderCoreController, orderChecklistCoreController)
        let stockCoreController = StockCoreController(inventoryCoreController, pickingCoreController, orderCoreController, orderMacroStatusCoreController)
        
        // User Stores
        
        catalog = Catalog(dataStore, updateController, brickLinkAPIClient)
        
        inventoryStore = InventoryStore(inventoryCoreController, stockCoreController)
        uploadStore = UploadStore(uploadCoreController, inventoryCoreController, catalog)
        
        orderStore = OrderStore(orderCoreController, orderChecklistCoreController, orderMacroStatusCoreController, pickingProgressCoreController, trackingMiddleController, feedbackCoreController, feedbackPostController)
        pickingStore = PickingStore(pickingCoreController, pickingProgressCoreController, orderCoreController)
        shippingStore = ShippingStore(shippingCoreController, orderCoreController)
        trackingStore = TrackingStore(trackingCoreController, trackingMiddleController)
        feedbackStore = FeedbackStore(feedbackCoreController, feedbackPostController, orderCoreController)
        refundStore = RefundStore(refundCoreController)
        
        transactionStore = TransactionStore(transactionCoreController)
        resultStore = ResultStore(orderCoreController, shippingCoreController, refundCoreController, transactionCoreController)
        
        updateStore = UpdateStore(updateController)
    }
}
