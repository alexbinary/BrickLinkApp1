
import SwiftUI



struct EnvInjector: PreviewModifier {


    static func makeSharedContext() async throws -> PreviewEnv {
        
        let env = createEnv()
        let nav = NavigationController()
        
        return PreviewEnv(env: env, nav: nav)
    }


    func body(content: Content, context: PreviewEnv) -> some View {
        
        content
            
            .environment(context.env.catalog)
        
            .environment(\.inventoryStore, PreviewInventoryStore())
            .environment(context.env.stores.upload)
        
            .environment(context.env.stores.order)
            .environment(\.pickingStore, PreviewPickingStore())
            .environment(context.env.stores.shipping)
            .environment(context.env.stores.tracking)
            .environment(context.env.stores.feedback)
            
            .environment(context.env.stores.refund)
        
            .environment(context.env.stores.transaction)
            .environment(context.env.stores.result)
        
            .environment(context.env.stores.update)
        
            .environment(context.nav)
    }
}



extension PreviewTrait where T == Preview.ViewTraits {
    
    static var env: PreviewTrait {
        
        PreviewTrait.modifier(EnvInjector())
    }
}



struct PreviewEnv {
    
    let env: Env
    let nav: NavigationController
}

