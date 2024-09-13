
import SwiftUI


enum SidebarItem {
    
    case orders
    case picking
    case upload
    
    case result
    case cashFlow
}


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var selectedSidebarItem: SidebarItem = .upload
    
    @State var ordersSelectedOrderId: OrderSummary.ID? = Secrets.Default.ordersSelectedOrderId
    @State var pickingSelectedOrderIds: Set<OrderSummary.ID> = Secrets.Default.pickingSelectedOrderIds
    
    @State var resultSelectedOrderIds: Set<OrderSummary.ID> = Secrets.Default.resultSelectedOrderIds
    @State var selectedTransactions: Set<Transaction.ID> = []
    
    var body: some View {
        
        NavigationSplitView {
            
            List(selection: $selectedSidebarItem) {
                
                Section("Operations") {
                    
                    Label("Orders", systemImage: "list.bullet")
                        .tag(SidebarItem.orders)
                    
                    Label("Picking", systemImage: "tray.and.arrow.up")
                        .tag(SidebarItem.picking)
                    
                    Label("Upload", systemImage: "tray.and.arrow.down")
                        .tag(SidebarItem.upload)
                }
                
                Section("Accounting") {
                    
                    Label("Result", systemImage: "eurosign.circle")
                        .tag(SidebarItem.result)
                    
                    Label("Cash flow", systemImage: "eurosign.circle")
                        .tag(SidebarItem.cashFlow)
                }
            }
            
        } content : {
            
            switch selectedSidebarItem {
                
            case .orders:
                OrdersContentView(selectedOrderId: $ordersSelectedOrderId)
            
            case .picking:
                PickingContentView(selectedOrderIds: $pickingSelectedOrderIds)
                
            case .upload:
                UploadContentView()
            
            case .result:
                ResultContentView(selectedOrderIds: $resultSelectedOrderIds)
            
            case .cashFlow:
                CashFlowContentView(selectedTransactions: $selectedTransactions)
            }
            
        } detail: {
            
            switch selectedSidebarItem {
            
            case .orders:
                OrdersDetailView(selectedOrderId: ordersSelectedOrderId)
            
            case .picking:
                PickingDetailView(selectedOrderIds: pickingSelectedOrderIds)
                
            case .upload:
                Color.clear
            
            case .result:
                ResultDetailView(selectedOrderIds: resultSelectedOrderIds)
            
            case .cashFlow:
                CashFlowDetailView(selectedTransactions: selectedTransactions)
            }
        }
    }
}
