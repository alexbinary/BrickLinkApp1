
import SwiftUI


enum SidebarItem {
    
    case orders
    case picking
    case compta
}


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedSidebarItem: SidebarItem = .compta
    
    @State var ordersSelectedOrderId: Order.ID? = Secrets.Default.ordersSelectedOrderId
    @State var pickingSelectedOrderIds: Set<Order.ID> = Secrets.Default.pickingSelectedOrderIds
    @State var selectedTransactions: Set<Transaction.ID> = []
    
    var body: some View {
        
        NavigationSplitView {
            
            List(selection: $selectedSidebarItem) {
                Label("Orders", systemImage: "list.bullet")
                    .tag(SidebarItem.orders)
                Label("Picking", systemImage: "tray.and.arrow.up")
                    .tag(SidebarItem.picking)
                Label("Compta", systemImage: "eurosign.circle")
                    .tag(SidebarItem.compta)
            }
            
        } content : {
            
            switch selectedSidebarItem {
            case .orders:
                OrdersContentView(selectedOrderId: $ordersSelectedOrderId)
            case .picking:
                PickingContentView(selectedOrderIds: $pickingSelectedOrderIds)
            case .compta:
                ComptaContentView(selectedTransactions: $selectedTransactions)
            }
            
        } detail: {
            
            switch selectedSidebarItem {
            case .orders:
                OrdersDetailView(selectedOrderId: ordersSelectedOrderId)
            case .picking:
                PickingDetailView(selectedOrderIds: pickingSelectedOrderIds)
            case .compta:
                ComptaDetailView(selectedTransactions: selectedTransactions)
            }
        }
    }
}
