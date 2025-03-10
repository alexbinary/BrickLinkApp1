
import SwiftUI



enum SidebarItem {
    
    case orders
    case upload
    
    case resultDashboard
    case resultHistory
    case cashFlow
}



struct WindowRootView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedSidebarItem: SidebarItem = Secrets.Defaults.selectedSidebarItem
    
    @State var ordersActiveNavigationPath: [OrderSummary.ID] = Secrets.Defaults.ordersActiveNavigationPath
    @State var resultSelectedOrderIds: Set<OrderSummary.ID> = Secrets.Defaults.resultSelectedOrderIds
    @State var selectedTransactions: Set<Transaction.ID> = []
        
    var body: some View {
        
        NavigationSplitView {
            
            List(selection: $selectedSidebarItem) {
                
                Section("Operations") {
                    
                    let actionOrders = appController.orderSummaries.filter {
                        
                        appController.orderBusinessStatus($0.id).isOneOf(.ship, .pickAndPack, .validatePayment, .giveFeedback)
                        ||
                        (appController.orderBusinessStatus($0.id) == .inTransit && appController.orderChecklistUnchangedFor30Days($0.id))
                    }
                    
                    Label("Orders", systemImage: "list.bullet")
                        .badge(actionOrders.count)
                        .tag(SidebarItem.orders)
                    
                    let uploadItems = appController.uploadItems
                    
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
