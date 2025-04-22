
import SwiftUI



extension View {

    
    func previewEnv(
    
        navigationController: NavigationControllerProtocol? = nil,
        catalog: CatalogProtocol? = nil,
        uploadStore: UploadStoreProtocol? = nil,
        orderStore: OrderStoreProtocol? = nil
        
    ) -> some View {
        
        self
            .environment(\.navigationController, navigationController ?? PreviewNavigationController())
        
            .environment(\.catalog, catalog ?? PreviewCatalog())
            .environment(\.inventoryStore, PreviewInventoryStore())
            .environment(\.uploadStore, uploadStore ?? PreviewUploadStore())
        
            .environment(\.orderStore, orderStore ?? PreviewOrderStore())
            .environment(\.pickingStore, PreviewPickingStore())
            .environment(\.shippingStore, PreviewShippingStore())
            .environment(\.trackingStore, PreviewTrackingStore())
            .environment(\.feedbackStore, PreviewFeedbackStore())
            
            .environment(\.refundStore, PreviewRefundStore())
            .environment(\.transactionStore, PreviewTransactionStore())
        
            .environment(\.resultStore, PreviewResultStore())
        
            .environment(\.updateStore, PreviewUpdateStore())
    }
}
