
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
    
    @State var selectedSidebarItem: SidebarItem = .orders
    
    @State var ordersSelectedOrderId: OrderSummary.ID? = Secrets.Default.ordersSelectedOrderId
    @State var resultSelectedOrderIds: Set<OrderSummary.ID> = Secrets.Default.resultSelectedOrderIds
    @State var selectedTransactions: Set<Transaction.ID> = []
    
    var body: some View {
        
        NavigationSplitView {
            
            List(selection: $selectedSidebarItem) {
                
                Section("Operations") {
                    
                    Label("Orders", systemImage: "list.bullet")
                        .tag(SidebarItem.orders)
                    
                    Label("Upload", systemImage: "tray.and.arrow.down")
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
            
        } content : {
            
            switch selectedSidebarItem {
                
            case .orders:
                OrdersContentView(selectedOrderId: $ordersSelectedOrderId)
                
            case .upload:
                UploadContentView()
                
            case .resultDashboard, .resultHistory:
                ResultContentView(selectedOrderIds: $resultSelectedOrderIds)
            
            case .cashFlow:
                CashFlowContentView(selectedTransactions: $selectedTransactions)
            }
            
        } detail: {
            
            switch selectedSidebarItem {
            
            case .orders:
                OrdersDetailView(selectedOrderId: ordersSelectedOrderId)
                
            case .upload:
                Color.clear
            
            case .resultDashboard:
                ResultDashboardView()
                
            case .resultHistory:
                ResultHistoryView(selectedOrderIds: $resultSelectedOrderIds)
            
            case .cashFlow:
                CashFlowDetailView(selectedTransactions: selectedTransactions)
            }
        }
    }
}
