
import SwiftUI



struct CashFlowContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var selectedTransactions: Set<Transaction.ID>
    
    
    var body: some View {
        
        TransactionListView(transactions: appController.transactions, selectedTransactions: $selectedTransactions)
            .navigationTitle("Cash Flow")
    }
}
