
import SwiftUI



struct CashFlowContentView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    @Environment(NavigationController.self)
    var nav
    
    
    var body: some View {
        
        @Bindable var nav = nav
        
        TransactionListView(
            transactions: app.transactions,
            selectedTransactions: $nav.selectedTransactions
        )
        .navigationTitle("Cash Flow")
    }
}
