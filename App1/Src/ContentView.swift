
import SwiftUI


struct ContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var ordersSelectedOrderId: Order.ID? = nil
    
    
    var body: some View {
        
        NavigationSplitView {
            
            List {
                Label("Orders", systemImage: "list.bullet")
            }
            
        } content : {
            
            OrdersContentView(selectedOrderId: $ordersSelectedOrderId)
            
        } detail: {
            
            OrdersDetailView(selectedOrderId: ordersSelectedOrderId)
        }
    }
}
