
import SwiftUI



struct Sidebar: View {
    
    
    @Environment(NavigationController.self)
    var nav
    
    @Environment(OrderController.self)
    var orderController
    
    @Environment(UploadController.self)
    var uploadController
    
    
    var body: some View {
            
        @Bindable var nav = nav
        List(selection: $nav.sidebar) {
            
            Section("Operations") {
                
                Label("Orders", systemImage: "list.bullet")
                    .badge(orderController.numberForSidebarBadge)
                    .tag(SidebarItem.orders)
                
                Label("Upload", systemImage: "tray.and.arrow.down")
                    .badge(uploadController.numberForSidebarBadge)
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



#Preview {
    
    let navigationController = NavigationController()
    
    let controllers = AppController.createControllers()
    let orderController = controllers.order
    let uploadController = controllers.upload
    
    Sidebar()
        .environment(navigationController)
        .environment(orderController)
        .environment(uploadController)
}
