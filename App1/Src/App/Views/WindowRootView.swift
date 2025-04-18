
import SwiftUI



struct WindowRootView: View {
    
    
    @Environment(\.updateStore)
    var updateStore: UpdateStoreProtocol!
    
    
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



#Preview(traits: .env) {
    WindowRootView()
        .frame(width: 1400, height: 800)
}
