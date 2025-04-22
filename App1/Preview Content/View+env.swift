
import SwiftUI



extension View {

    
    func env(
    
        selectedSidebarItem: SidebarItem = .orders,
        ordersNumberForSidebarBadge: Int = 1,
        uploadNumberForSidebarBadge: Int = 2
        
    ) -> some View {
        
        self
            .environment(\.navigationController, PreviewNavigationController(
                sidebar: selectedSidebarItem
            ))
        
            .environment(\.catalog, PreviewCatalog())
        
            .environment(\.inventoryStore, PreviewInventoryStore())
        
            .environment(\.uploadStore, PreviewUploadStore(
                numberForSidebarBadge: uploadNumberForSidebarBadge
            ))
        
            .environment(\.orderStore, PreviewOrderStore(
                numberForSidebarBadge: ordersNumberForSidebarBadge
            ))
            
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
