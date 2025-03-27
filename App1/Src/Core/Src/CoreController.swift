
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
    
    
    public init(brickLinkCredentials: BrickLinkAPICredentials, debug: Debug) {
        
        let dataStore: DataStore = {
            let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
            return DataStore(dataFileUrl: URL(fileURLWithPath: path))
        }()
        
        let brickLinkAPIClient = BrickLinkAPIClient(withCredentials: brickLinkCredentials, debug: debug)
        
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
        
        catalog = Catalog(dataStore, brickLinkAPIClient)
        
        inventoryStore = InventoryStore(inventoryCoreController, stockCoreController)
        uploadStore = UploadStore(uploadCoreController, inventoryCoreController, catalog)
        
        orderStore = OrderStore(orderCoreController, orderChecklistCoreController, orderMacroStatusCoreController, pickingProgressCoreController, trackingMiddleController, feedbackCoreController, feedbackPostController)
        pickingStore = PickingStore(pickingCoreController, pickingProgressCoreController, orderCoreController)
        shippingStore = ShippingStore(shippingCoreController, orderCoreController)
        trackingStore = TrackingStore(trackingMiddleController)
        feedbackStore = FeedbackStore(feedbackCoreController, feedbackPostController)
        refundStore = RefundStore(refundCoreController)
        
        transactionStore = TransactionStore(transactionCoreController)
        resultStore = ResultStore(orderCoreController, shippingCoreController, refundCoreController, transactionCoreController)
    }
}
