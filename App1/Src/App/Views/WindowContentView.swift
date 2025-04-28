
import SwiftUI



struct WindowContentView: View {
    
    
    @Environment(\.navigationController)
    var nav: NavigationControllerProtocol!
        
    
    var body: some View {
        
        let navOrderStackBinding = Binding {
            nav.orderStack
        } set: {
            nav.orderStack = $0
        }
         
        switch nav.sidebar {
            
        case .orders:
            
            NavigationStack(path: navOrderStackBinding) {
                OrdersMainList()
            }
            
        case .upload:
            
            UploadRootView()
            
        case .inventory:
            
            InventoryListView()
            
        case .resultDashboard:
            
            HSplitView {
                ResultContentView()
                ResultDashboard()
            }
            
        case .resultHistory:
            
            HSplitView {
                ResultContentView()
                ResultHistoryView()
            }
            
        case .cashFlow:
            
            HSplitView {
                CashFlowContentView()
                CashFlowDetailView()
            }
        }
    }
}



#Preview {
    
    NavigationSplitView {
        
        Sidebar()
            .frame(minWidth: 180)
        
    } detail: {
    
        WindowContentView()
            .frame(width: 1000, height: 800)
            
    }
    .previewEnv()
}
