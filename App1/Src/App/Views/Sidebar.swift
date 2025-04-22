
import SwiftUI



struct Sidebar: View {
    
    
    @Environment(\.navigationController)
    var nav: NavigationControllerProtocol!
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    
    var body: some View {
            
        let navSidebarBinding = Binding {
            nav.sidebar
        } set: {
            nav.sidebar = $0
        }
        List(selection: navSidebarBinding) {
            
            Section("Operations") {
                
                Label("Orders", systemImage: "list.bullet")
                    .badge(orderStore.numberForSidebarBadge)
                    .tag(SidebarItem.orders)
                
                Label("Upload", systemImage: "tray.and.arrow.down")
                    .badge(uploadStore.numberForSidebarBadge)
                    .tag(SidebarItem.upload)
            }
            
            Section("Result") {
                
                Label("Dashboard", systemImage: "gauge.open.with.lines.needle.33percent")
                    .tag(SidebarItem.resultDashboard)
                
                Label("History", systemImage: "list.bullet")
                    .tag(SidebarItem.resultHistory)
            }
            
            Section("Accounting") {
                
                Label("Cash flow", systemImage: "eurosign.circle")
                    .tag(SidebarItem.cashFlow)
            }
        }
    }
}



#Preview(traits: .env) {
    
    NavigationSplitView {
        
        Sidebar()
        
    } detail: {
        
    }
}
