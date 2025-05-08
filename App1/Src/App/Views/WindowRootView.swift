
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
            
            OrderStatusView()
        }
        .environment(\.navigationController, navigationController)
    }
}



#Preview {
    WindowRootView()
        .frame(width: 1200, height: 800)
        .previewEnv()
}
