
import SwiftUI



struct WindowRootView: View {
    
    
    @State
    var navigationController = NavigationController()
    
    
    var body: some View {
        
        NavigationSplitView {
            
            SidebarView()
            
        } detail: {
            
            WindowContentView()
        }
        .environment(navigationController)
    }
}
