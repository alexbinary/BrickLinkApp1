
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
        result: ResultStore,
        
        update: UpdateStore
    )
)



@MainActor
public func createEnv() -> Env {
    
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
