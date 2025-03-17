
import SwiftUI


@main
struct MainApp: App {
    
    
    @StateObject
    private var appController = AppController()
    
    
    var body: some Scene {
        
        WindowGroup {
            
            WindowRootView()
                .environmentObject(appController)
                .environment(appController.orderStore)
                .environment(appController.pickingStore)
                .environment(appController.shippingStore)
                .environment(appController.pickingController)
                .environment(appController.shippingController)
        }
    }
}
