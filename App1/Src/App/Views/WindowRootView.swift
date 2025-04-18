
import SwiftUI



struct WindowRootView: View {
    
    
    @Environment(UpdateStore.self)
    var updateStore
    
    
    @State
    var navigationController = NavigationController()
    
    
    var body: some View {
        
        NavigationSplitView {
            
            Sidebar()
            
        } detail: {
            
            WindowContentView()
        }
        .toolbar {
            
            if updateStore.isLoadingOperations {
                ProgressView()
                    .controlSize(.small)
            }
            
            ReloadButton()
        }
        .environment(navigationController)
    }
}
