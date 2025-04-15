
import Foundation



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
        
        let inventoryController = InventoryController(dataStore, updateController, brickLinkAPIClient)
        let uploadController = UploadController(dataStore)
        
        let orderController = OrderController(dataStore, updateController)
        let pickingController = PickingController(dataStore)
        let shippingController = ShippingController(dataStore)
        let trackingController = TrackingController(dataStore, updateController)
        let feedbackController = FeedbackController(dataStore, updateController)
        let refundController = RefundController(dataStore)
        let transactionController = TransactionController(dataStore)
        
        let trackingMiddleController = TrackingMiddleController(trackingController, orderController)
        let feedbackPostController = FeedbackPostController(feedbackController, orderController)
        
        let pickingProgressController = PickingProgressController(pickingController, orderController)
        let checklistController = ChecklistController(orderController, pickingController, shippingController, feedbackController, transactionController, trackingMiddleController, pickingProgressController)
        let macroStatusController = MacroStatusController(orderController, checklistController)
        let stockController = StockController(inventoryController, pickingController, orderController, macroStatusController)
        
        // User Stores
        
        catalog = Catalog(dataStore, updateController, brickLinkAPIClient)
        
        inventoryStore = InventoryStore(inventoryController, stockController)
        uploadStore = UploadStore(uploadController, inventoryController, catalog)
        
        orderStore = OrderStore(orderController, checklistController, macroStatusController, pickingProgressController, trackingMiddleController, feedbackController, feedbackPostController)
        pickingStore = PickingStore(pickingController, pickingProgressController, orderController)
        shippingStore = ShippingStore(shippingController, orderController)
        trackingStore = TrackingStore(trackingController, trackingMiddleController)
        feedbackStore = FeedbackStore(feedbackController, feedbackPostController, orderController)
        refundStore = RefundStore(refundController)
        
        transactionStore = TransactionStore(transactionController)
        resultStore = ResultStore(orderController, shippingController, refundController, transactionController)
        
        updateStore = UpdateStore(updateController)
    }
}
