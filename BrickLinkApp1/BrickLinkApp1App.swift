
import SwiftUI


@main
struct BrickLinkApp1App: App {
    
    
    @StateObject private var appController: AppController
    
    
    init() {
        
        let appController = AppController()
        
        _appController = StateObject(wrappedValue: appController)
    }
    
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView()
                .environmentObject(appController)
        }
    }
}
