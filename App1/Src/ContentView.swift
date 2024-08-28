
import SwiftUI


enum SidebarItem {
    
    case orders
    case picking
}


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedSidebarItem: SidebarItem = .orders
    
    @State var ordersSelectedOrderId: Order.ID? = nil
    @State var pickingSelectedOrderId: Order.ID? = nil
    
    var body: some View {
        
        NavigationSplitView {
            
            List(selection: $selectedSidebarItem) {
                Label("Orders", systemImage: "list.bullet")
                    .tag(SidebarItem.orders)
                Label("Picking", systemImage: "tray.and.arrow.up")
                    .tag(SidebarItem.picking)
            }
            
        } content : {
            
            switch selectedSidebarItem {
            case .orders:
                OrdersContentView(selectedOrderId: $ordersSelectedOrderId)
            case .picking:
                PickingContentView(selectedOrderId: $pickingSelectedOrderId)
            }
            
        } detail: {
            
            switch selectedSidebarItem {
            case .orders:
                OrdersDetailView(selectedOrderId: ordersSelectedOrderId)
            case .picking:
                PickingDetailView(selectedOrderId: pickingSelectedOrderId)
            }
        }
    }
}
