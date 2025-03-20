
import SwiftUI


@main
struct MainApp: App {
    
    
    var body: some Scene {
        
        let env = createEnv()
        
        WindowGroup {
            
            WindowRootView()
                
                .inject(env)

                .task { await parallel([
                    { await env.catalog.loadColors() },
                    { await env.stores.inventory.loadInventories() },
                    { await env.stores.order.loadOrderSummaries() },
                ])}
        }
    }
}



extension View {
    
    
    @ViewBuilder
    func inject(_ env: Env) -> some View {

        self
            .environment(env.catalog)
        
            .environment(env.stores.inventory)
            .environment(env.stores.upload)
            .environment(env.stores.stock)
        
            .environment(env.stores.order)
            .environment(env.stores.picking)
            .environment(env.stores.shipping)
            .environment(env.stores.tracking)
            .environment(env.stores.feedback)
            
            .environment(env.stores.refund)
        
            .environment(env.stores.transaction)
            .environment(env.stores.result)

            .environment(env.stores.orderChecklist)
            .environment(env.stores.orderAction)
            
            .environment(env.controllers.feedback)
            .environment(env.controllers.reload)
    }
}
