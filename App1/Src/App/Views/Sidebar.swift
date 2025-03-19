
import SwiftUI



struct Sidebar: View {
    
    
    @Environment(UploadStore.self)
    var uploadStore
    
    @Environment(OrderActionController.self)
    var orderActionController
    
    @Environment(NavigationController.self)
    var nav
    
    
    var body: some View {
            
        @Bindable var nav = nav
        List(selection: $nav.sidebar) {
            
            Section("Operations") {
                
                Label("Orders", systemImage: "list.bullet")
                    .badge(orderActionController.actionOrders.count)
                    .tag(SidebarItem.orders)
                
                Label("Upload", systemImage: "tray.and.arrow.down")
                    .badge(uploadStore.uploadItems.count)
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
