
import SwiftUI



struct WindowContentView: View {
    
    
    let selectedSidebarItem: SidebarItem
    
    @Binding var ordersActiveNavigationPath: [OrderSummary.ID]
    @Binding var resultSelectedOrderIds: Set<OrderSummary.ID>
    @Binding var selectedTransactions: Set<Transaction.ID>
        
    var body: some View {
        
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
