
import SwiftUI


struct ContentView: View {
    
    var body: some View {
        
        NavigationSplitView {
            
            Text("Sidebar")
            
        } detail: {
            
            Text("Content")
                .navigationTitle("Content")
        }
    }
}
