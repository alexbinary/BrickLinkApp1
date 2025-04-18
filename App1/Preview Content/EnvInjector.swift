
import SwiftUI



struct EnvInjector: PreviewModifier {
    
    
    struct PreviewEnv {
        
        let env: Env
        let nav: NavigationController
    }


    static func makeSharedContext() async throws -> PreviewEnv {
        
        let env = (
            
            catalog: PreviewCatalog(),
                    
            stores: (
                
                inventory: PreviewInventoryStore(),
                upload: PreviewUploadStore(),
                
                order: PreviewOrderStore(),
                picking: PreviewPickingStore(),
                shipping: PreviewShippingStore(),
                tracking: PreviewTrackingStore(),
                feedback: PreviewFeedbackStore(),
                refund: PreviewRefundStore(),
                
                transaction: PreviewTransactionStore(),
                result: PreviewResultStore(),
                
                update: PreviewUpdateStore()
            )
        )
            
        let nav = NavigationController()
        
        return PreviewEnv(env: env, nav: nav)
    }


    func body(content: Content, context: PreviewEnv) -> some View {
        
        content
            .inject(context.env)
            .environment(context.nav)
            .environment(\.navigationController, context.nav)
    }
}



extension PreviewTrait where T == Preview.ViewTraits {
    
    static var env: PreviewTrait {
        
        PreviewTrait.modifier(EnvInjector())
    }
}
