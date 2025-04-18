
import SwiftUI



struct EnvInjector: PreviewModifier {


    static func makeSharedContext() async throws -> PreviewEnv {
        
        let env = createEnv()
        let nav = NavigationController()
        
        return PreviewEnv(env: env, nav: nav)
    }


    func body(content: Content, context: PreviewEnv) -> some View {
        
        content
            .inject(context.env)
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

