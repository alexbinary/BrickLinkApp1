
import SwiftUI



struct SidebarView: View {
    
    
    @EnvironmentObject var app: AppController
    
    @Binding var selectedItem: SidebarItem
    
    
    var body: some View {
            
        List(selection: $selectedItem) {
            
            Section("Operations") {
                
                Label("Orders", systemImage: "list.bullet")
                    .badge(app.actionOrders.count)
                    .tag(SidebarItem.orders)
                
                Label("Upload", systemImage: "tray.and.arrow.down")
                    .badge(app.uploadItems.count)
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
