
import SwiftUI


@main
struct MainApp: App {
    
    
    var body: some Scene {
        
        let controllers = AppController.createControllers()
        
        WindowGroup {
            
            WindowRootView()
                
                .environment(controllers.catalog)
                .environment(controllers.inventory)
                .environment(controllers.upload)
                .environment(controllers.stock)
            
                .environment(controllers.order)
                .environment(controllers.picking)
                .environment(controllers.shipping)
                .environment(controllers.tracking)
                .environment(controllers.feedback)
                .environment(controllers.refund)
            
                .environment(controllers.transaction)
                .environment(controllers.result)

                .environment(controllers.reload)
                .environment(controllers.orderChecklist)
                .environment(controllers.orderAction)

                .task { await parallel([
                    { await controllers.catalog.loadColors() },
                    { await controllers.inventory.loadInventories() },
                    { await controllers.order.loadOrderSummaries() },
                ])}
        }
    }
}
