
import SwiftUI
import Charts



struct ComptaDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
    let selectedTransactions: Set<Transaction.ID>
    
    
    var body: some View {
        
        let allTransactions = appController.transactions.sorted { $0.date > $1.date }
        let allTransactionsGrouppedByMonth = allTransactions.grouppedByMonth
        
        ScrollView {
            
            VStack(spacing: 36) {
                
                ComptaDetailDashboardItemView(
                    transactions: allTransactions,
                    title: "All time"
                )
                
                Divider()
                
                if !selectedTransactions.isEmpty {
                    
                    ComptaDetailDashboardItemView(
                        transactions: allTransactions.filter { selectedTransactions.contains($0.id) },
                        title: "Selection"
                    )
                    
                    Divider()
                }
                
                ForEach(allTransactionsGrouppedByMonth, id: \.month) {
                    
                    ComptaDetailDashboardItemView(
                        transactions: $0.transactions,
                        title: $0.month
                    )
                    
                    Divider()
                }
            }
            .padding(24)
        }
    }
}
