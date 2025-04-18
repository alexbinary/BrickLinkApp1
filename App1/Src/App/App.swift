
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
            .environment(env.catalog)
        
            .environment(env.stores.inventory)
            .environment(env.stores.upload)
        
            .environment(env.stores.order)
            .environment(\.pickingStore, env.stores.picking)
            .environment(env.stores.shipping)
            .environment(env.stores.tracking)
            .environment(env.stores.feedback)
            
            .environment(env.stores.refund)
        
            .environment(env.stores.transaction)
            .environment(env.stores.result)
        
            .environment(env.stores.update)
    }
}
