
import SwiftUI



struct EnvInjector: PreviewModifier {


    static func makeSharedContext() async throws -> PreviewEnv {
        
        let env = createEnv()
        let nav = NavigationController()
        
        return PreviewEnv(env: env, nav: nav)
    }


    func body(content: Content, context: PreviewEnv) -> some View {
        
        content
            
            .environment(\.catalog, PreviewCatalog())
        
            .environment(\.inventoryStore, PreviewInventoryStore())
            .environment(\.uploadStore, PreviewUploadStore())
        
            .environment(\.orderStore, PreviewOrderStore())
            .environment(\.pickingStore, PreviewPickingStore())
            .environment(\.shippingStore, PreviewShippingStore())
            .environment(\.trackingStore, PreviewTrackingStore())
            .environment(\.feedbackStore, PreviewFeedbackStore())
            
            .environment(\.refundStore, PreviewRefundStore())
        
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

