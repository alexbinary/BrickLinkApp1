
import SwiftUI
import Core



struct WindowRootView: View {
    
    
    @Environment(Catalog.self)
    var catalog
    
    @Environment(InventoryStore.self)
    var inventoryStore
    
    @Environment(OrderStore.self)
    var orderStore
    
    @Environment(TrackingStore.self)
    var trackingStore
    
    @Environment(FeedbackStore.self)
    var feedbackStore
    
    
    @State
    var navigationController = NavigationController()
    
    
    var body: some View {
        
        NavigationSplitView {
            
            Sidebar()
            
        } detail: {
            
            WindowContentView()
        }
        .toolbar {
            
            if isLoading {
                Text("updating...")
            }
            
            ReloadButton()
        }
        .environment(navigationController)
    }
    
    
    var isLoading: Bool {
        [
            catalog.isLoadingColors,
            inventoryStore.isLoadingInventories,
            
            orderStore.isLoadingOrders,
            orderStore.isLoadingOrderDetails,
            orderStore.isLoadingOrderItems,
            
            orderStore.isUpdatingOrderStatus,
            orderStore.isUpdatingOrderTrackingNo,
            orderStore.isSendingDriveThru,
            
            trackingStore.isLoadingLaPosteTrackingStatus,
            
            feedbackStore.isLoadingOrderFeedbacks,
            feedbackStore.isPostingFeedback
            
        ].contains(true)
    }
}
