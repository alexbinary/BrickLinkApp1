
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
        }
    }
}
