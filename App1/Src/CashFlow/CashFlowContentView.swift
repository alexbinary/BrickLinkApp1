
import SwiftUI



struct CashFlowContentView: View {
    
    
    @Environment(TransactionStore.self)
    var transactionStore
    
    @Environment(NavigationController.self)
    var nav
    
    
    var body: some View {
        
        @Bindable var nav = nav
        
        TransactionListView(
            transactions: transactionStore.transactions,
            selectedTransactions: $nav.selectedTransactions
        )
        .navigationTitle("Cash Flow")
    }
}
