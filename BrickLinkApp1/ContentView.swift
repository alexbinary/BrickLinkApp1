
import SwiftUI


struct Order: Identifiable {
    
    let id: String
}


struct ContentView: View {
    
    let orders: [Order] = [
        Order(id: "#1"),
        Order(id: "#2"),
    ]
    
    var body: some View {
        
        NavigationSplitView {
            
            List {
                Label("Orders", systemImage: "list.bullet")
            }
            
        } detail: {
            
            Table(orders) {
                
                TableColumn("ID", value: \.id)
                
            }
                .navigationTitle("Orders")
        }
    }
}
