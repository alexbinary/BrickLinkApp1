
import SwiftUI


@main
struct App1: App {
    
    
    @StateObject private var appController: AppController
    
    
    init() {
        
        let dataFileUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath.appending("/data/data.json5"))
        let dataStore = DataStore(dataFileUrl: dataFileUrl)
        
        let blCredentials = BrickLinkAPICredentials()
        
        let appController = AppController(
            dataStore: dataStore, blCredentials: blCredentials
        )
        _appController = StateObject(wrappedValue: appController)
    }
    
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView()
                .environmentObject(appController)
        }
    }
}
