
import SwiftUI


@main
struct MainApp: App {
    
    
    var body: some Scene {
        
        let stores = createStores()
        
        WindowGroup {
            
            WindowRootView()
                
                .environment(stores.catalog)
                .environment(stores.inventory)
                .environment(stores.upload)
                .environment(stores.stock)
            
                .environment(stores.order)
                .environment(stores.picking)
                .environment(stores.shipping)
                .environment(stores.tracking)
                .environment(stores.feedback)
                .environment(stores.refund)
            
                .environment(stores.transaction)
                .environment(stores.result)

                .environment(stores.reload)
                .environment(stores.orderChecklist)
                .environment(stores.orderAction)

                .task { await parallel([
                    { await stores.catalog.loadColors() },
                    { await stores.inventory.loadInventories() },
                    { await stores.order.loadOrderSummaries() },
                ])}
        }
    }
}
