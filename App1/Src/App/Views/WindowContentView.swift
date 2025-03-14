
import SwiftUI



struct WindowContentView: View {
    
    
    @Environment(NavigationController.self)
    var nav
        
    
    var body: some View {
        
        @Bindable var nav = nav
        
        switch nav.sidebar {
            
        case .orders:
            
            NavigationStack(path: $nav.orders) {
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
