
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
            
            UploadView()
            
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



#Preview(traits: .env) {
    WindowContentView()
        .frame(width: 1400, height: 800)
}
