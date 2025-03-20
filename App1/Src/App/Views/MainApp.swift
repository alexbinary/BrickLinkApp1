
import SwiftUI


@main
struct MainApp: App {
    
    
    var body: some Scene {
        
        let controllers = AppController.createControllers()
        
        WindowGroup {
            
            WindowRootView()
                
                .environment(controllers.catalogStore)
                .environment(controllers.inventoryStore)

                .environment(controllers.transactionController)
                .environment(controllers.refundController)

                .environment(controllers.orderStore)
                .environment(controllers.pickingStore)
                .environment(controllers.trackingStore)

                .environment(controllers.uploadController)
                .environment(controllers.pickingController)
                .environment(controllers.shippingController)
                .environment(controllers.trackingController)
                .environment(controllers.feedbackController)

                .environment(controllers.orderChecklistController)
                .environment(controllers.resultController)

                .environment(controllers.orderController)
                .environment(controllers.stockController)
                .environment(controllers.reloadController)
                .environment(controllers.orderActionController)

                .task { await parallel([
                    { await controllers.catalogStore.loadColors() },
                    { await controllers.inventoryStore.loadInventories() },
                    { await controllers.orderStore.loadOrderSummaries() },
                ])}
        }
    }
}
