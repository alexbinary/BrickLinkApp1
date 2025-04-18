
import SwiftUI



struct CashFlowContentView: View {
    
    
    @Environment(\.transactionStore)
    var transactionStore: TransactionStoreProtocol!
    
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
