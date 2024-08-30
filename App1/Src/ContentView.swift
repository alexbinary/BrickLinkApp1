
import SwiftUI


enum SidebarItem {
    
    case orders
    case picking
}


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedSidebarItem: SidebarItem = .picking
    
    @State var ordersSelectedOrderId: Order.ID? = nil
    @State var pickingSelectedOrderIds: Set<Order.ID> = ["26050777"]
    
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
                PickingContentView(selectedOrderIds: $pickingSelectedOrderIds)
            }
            
        } detail: {
            
            switch selectedSidebarItem {
            case .orders:
                OrdersDetailView(selectedOrderId: ordersSelectedOrderId)
            case .picking:
                PickingDetailView(selectedOrderIds: pickingSelectedOrderIds)
            }
        }
    }
}
