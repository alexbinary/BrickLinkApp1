
import SwiftUI


enum SidebarItem {
    
    case orders
    case upload
    
    case resultDashboard
    case resultHistory
    case cashFlow
}


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedSidebarItem: SidebarItem = Secrets.Default.selectedSidebarItem
    
    @State var ordersActiveNavigationPath: [OrderSummary.ID] = Secrets.Default.ordersActiveNavigationPath
    @State var resultSelectedOrderIds: Set<OrderSummary.ID> = Secrets.Default.resultSelectedOrderIds
    @State var selectedTransactions: Set<Transaction.ID> = []
        
    var body: some View {
        
        NavigationSplitView {
            
            List(selection: $selectedSidebarItem) {
                
                Section("Operations") {
                    
                    let openOrders = appController.orderSummaries.filter { appController.orderBusinessStatus($0.id) != .closed }
                    
                    Label("Orders (\(openOrders.count))", systemImage: "list.bullet")
                        .tag(SidebarItem.orders)
                    
                    let uploadItems = appController.uploadItems
                    
                    Label("Upload (\(uploadItems.count))", systemImage: "tray.and.arrow.down")
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
            
        } detail: {
            
            switch selectedSidebarItem {
                
            case .orders:
                NavigationStack(path: $ordersActiveNavigationPath) {
                    OrdersListView(ordersActiveNavigationPath: $ordersActiveNavigationPath)
                }
                
            case .upload:
                UploadContentView()
                
            case .resultDashboard:
                HSplitView {
                    ResultContentView(selectedOrderIds: $resultSelectedOrderIds)
                    ResultDashboardView()
                }
                
            case .resultHistory:
                HSplitView {
                    ResultContentView(selectedOrderIds: $resultSelectedOrderIds)
                    ResultHistoryView(selectedOrderIds: $resultSelectedOrderIds)
                }
                
            case .cashFlow:
                HSplitView {
                    CashFlowContentView(selectedTransactions: $selectedTransactions)
                    CashFlowDetailView(selectedTransactions: selectedTransactions)
                }
            }
        }
    }
}
