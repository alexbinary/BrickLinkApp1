
import SwiftUI



@main
struct MainApp: App {
    
    
    var body: some Scene {
        
        let env = createEnv()
        
        WindowGroup {
            
            WindowRootView()
                .inject(env)
                .task { await env.catalog.loadColors() }
        }
    }
}



extension View {
    
    
    @ViewBuilder
    func inject(_ env: Env) -> some View {

        self
            .environment(\.catalog, env.catalog)
        
            .environment(\.inventoryStore, env.stores.inventory)
            .environment(\.uploadStore, env.stores.upload)
        
            .environment(\.orderStore, env.stores.order)
            .environment(\.pickingStore, env.stores.picking)
            .environment(\.shippingStore, env.stores.shipping)
            .environment(\.trackingStore, env.stores.tracking)
            .environment(env.stores.feedback)
            
            .environment(env.stores.refund)
        
            .environment(env.stores.transaction)
            .environment(env.stores.result)
        
            .environment(env.stores.update)
    }
}
