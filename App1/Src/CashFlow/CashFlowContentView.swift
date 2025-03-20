
import SwiftUI



struct CashFlowContentView: View {
    
    
    @Environment(TransactionController.self)
    var transactionController
    
    @Environment(NavigationController.self)
    var nav
    
    
    var body: some View {
        
        @Bindable var nav = nav
        
        TransactionListView(
            transactions: transactionController.allTransactions,
            selectedTransactions: $nav.selectedTransactions
        )
        .navigationTitle("Cash Flow")
    }
}
