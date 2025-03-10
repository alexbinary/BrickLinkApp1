
import SwiftUI



struct WindowContentView: View {
    
    
    @Environment(NavigationController.self)
    var nav
        
    
    var body: some View {
        
        @Bindable var nav = nav
        
        switch nav.sidebar {
            
        case .orders:
            
            NavigationStack(path: $nav.orders) {
                OrdersMainListView()
            }
            
        case .upload:
            
            UploadContentView()
            
        case .resultDashboard:
            
            HSplitView {
                ResultContentView()
                ResultDashboardView()
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
