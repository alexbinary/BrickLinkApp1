
import SwiftUI



struct WindowRootView: View {
    
    
    @State
    var navigationController = NavigationController()
    
    
    var body: some View {
        
        NavigationSplitView {
            
            Sidebar()
            
        } detail: {
            
            WindowContentView()
        }
        .environment(navigationController)
    }
}
