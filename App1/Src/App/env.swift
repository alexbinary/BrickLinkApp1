
import Foundation



typealias Env = (
    
    catalog: CatalogProtocol,
    
    stores: (
        
        inventory: InventoryStoreProtocol,
        upload: UploadStoreProtocol,

        order: OrderStoreProtocol,
        picking: PickingStoreProtocol,
        shipping: ShippingStoreProtocol,
        tracking: TrackingStoreProtocol,
        feedback: FeedbackStoreProtocol,
        refund: RefundStoreProtocol,

        transaction: TransactionStoreProtocol,
        result: ResultStoreProtocol,
        
        update: UpdateStoreProtocol
    )
)



@MainActor
func createEnv() -> Env {
    
    let coreController = CoreController(
        brickLinkCredentials: Secrets.brickLinkAPICredentials,
        debug: Debug(
            printRequest: Secrets.Network.printRequest,
            printResponse: Secrets.Network.printResponse
        )
    )
    
    return (
        
        catalog: coreController.catalog,
                
        stores: (
            
            inventory: coreController.inventoryStore,
            upload: coreController.uploadStore,
            
            order: coreController.orderStore,
            picking: coreController.pickingStore,
            shipping: coreController.shippingStore,
            tracking: coreController.trackingStore,
            feedback: coreController.feedbackStore,
            refund: coreController.refundStore,
            
            transaction: coreController.transactionStore,
            result: coreController.resultStore,
            
            update: coreController.updateStore
        )
    )
}
