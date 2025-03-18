
import SwiftUI


@main
struct MainApp: App {
    
    
    @StateObject
    private var appController = AppController()
    
    
    var body: some Scene {
        
        WindowGroup {
            
            WindowRootView()
                .environmentObject(appController)
                
                .environment(appController.catalogStore)
                .environment(appController.uploadStore)
                .environment(appController.inventoryStore)
                
                .environment(appController.transactionStore)
                .environment(appController.refundStore)
            
                .environment(appController.orderStore)
                .environment(appController.pickingStore)
                .environment(appController.shippingStore)
                .environment(appController.trackingStore)
                .environment(appController.feedbackStore)
                
                .environment(appController.uploadController)
                .environment(appController.pickingController)
                .environment(appController.shippingController)
                .environment(appController.trackingController)
                .environment(appController.feedbackController)
            
                .environment(appController.orderChecklistController)
                .environment(appController.resultController)
        }
    }
}
