
import SwiftUI



struct WindowRootView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedSidebarItem: SidebarItem = Secrets.Defaults.selectedSidebarItem
    
    @State var ordersActiveNavigationPath: [OrderSummary.ID] = Secrets.Defaults.ordersActiveNavigationPath
    @State var resultSelectedOrderIds: Set<OrderSummary.ID> = Secrets.Defaults.resultSelectedOrderIds
    @State var selectedTransactions: Set<Transaction.ID> = []
        
    var body: some View {
        
        NavigationSplitView {
            
            SidebarView(selectedItem: $selectedSidebarItem)
            
        } detail: {
            
            WindowContentView(
                selectedSidebarItem: selectedSidebarItem,
                ordersActiveNavigationPath: $ordersActiveNavigationPath,
                resultSelectedOrderIds: $resultSelectedOrderIds,
                selectedTransactions: $selectedTransactions
            )
        }
    }
}
