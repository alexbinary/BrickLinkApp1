
import SwiftUI


@main
struct App1: App {
    
    
    @StateObject private var appController = AppController()
    
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView()
                .environmentObject(appController)
        }
    }
}
