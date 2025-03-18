
import SwiftUI


@main
struct MainApp: App {
    
    
    @StateObject
    private var appController = AppController()
    
    
    var body: some Scene {
        
        WindowGroup {
            
            WindowRootView()
                .environmentObject(appController)
                
                .environment(appController.colorStore)
                .environment(appController.orderStore)
                .environment(appController.pickingStore)
                .environment(appController.shippingStore)
                .environment(appController.feedbackStore)
                
                .environment(appController.pickingController)
                .environment(appController.shippingController)
                .environment(appController.feedbackController)
        }
    }
}
