
import SwiftUI



struct CashFlowContentView: View {
    
    
    @EnvironmentObject var app: AppController
    
    @Binding var selectedTransactions: Set<Transaction.ID>
    
    
    var body: some View {
        
        TransactionListView(transactions: app.transactions, selectedTransactions: $selectedTransactions)
            .navigationTitle("Cash Flow")
    }
}
