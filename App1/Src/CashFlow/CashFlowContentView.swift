
import SwiftUI
import Core



struct CashFlowContentView: View {
    
    
    @Environment(TransactionUserStore.self)
    var transactionStore
    
    @Environment(NavigationController.self)
    var nav
    
    
    var body: some View {
        
        @Bindable var nav = nav
        
        TransactionListView(
            transactions: transactionStore.allTransactions,
            selectedTransactions: $nav.selectedTransactions
        )
        .navigationTitle("Cash Flow")
    }
}
