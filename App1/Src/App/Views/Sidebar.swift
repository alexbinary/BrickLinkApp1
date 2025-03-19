
import SwiftUI



struct Sidebar: View {
    
    
    @Environment(NavigationController.self)
    var nav
    
    @Environment(OrderController.self)
    var orderController
    
    @Environment(UploadStore.self)
    var uploadStore
    
    
    var body: some View {
            
        @Bindable var nav = nav
        List(selection: $nav.sidebar) {
            
            Section("Operations") {
                
                Label("Orders", systemImage: "list.bullet")
                    .badge(orderController.ordersThatNeedAction.count)
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



#Preview {
    
    let navigationController = NavigationController()
    
    let controllers = AppController.createControllers()
    let orderController = controllers.orderController
    
    let uploadStore = controllers.uploadStore
    
    Sidebar()
        .environment(navigationController)
        .environment(orderController)
        .environment(uploadStore)
}
