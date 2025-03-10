
import SwiftUI



struct SidebarView: View {
    
    
    @EnvironmentObject var app: AppController
    
    @Binding var selectedItem: SidebarItem
    
    
    var body: some View {
            
        List(selection: $selectedItem) {
            
            Section("Operations") {
                
                let actionOrders = app.orderSummaries.filter {
                    
                    app.orderBusinessStatus($0.id).isOneOf(.ship, .pickAndPack, .validatePayment, .giveFeedback)
                    ||
                    (app.orderBusinessStatus($0.id) == .inTransit && app.orderChecklistUnchangedFor30Days($0.id))
                }
                
                Label("Orders", systemImage: "list.bullet")
                    .badge(actionOrders.count)
                    .tag(SidebarItem.orders)
                
                let uploadItems = app.uploadItems
                
                Label("Upload", systemImage: "tray.and.arrow.down")
                    .badge(uploadItems.count)
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
