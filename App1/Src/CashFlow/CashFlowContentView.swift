
import SwiftUI



struct CashFlowContentView: View {
    
    
    @Environment(\.transactionStore)
    var transactionStore: TransactionStoreProtocol!
    
    @Environment(\.navigationController)
    var nav: NavigationControllerProtocol!
    
    
    var body: some View {
        
        let navSelectedTransactionsBinding = Binding {
            nav.selectedTransactions
        } set: {
            nav.selectedTransactions = $0
        }
        TransactionListView(
            transactions: transactionStore.allTransactions,
            selectedTransactions: navSelectedTransactionsBinding
        )
        .navigationTitle("Cash Flow")
    }
}
