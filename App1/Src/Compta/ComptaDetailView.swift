
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
                
                if !selectedTransactions.isEmpty {
                    
                    ComptaDetailDashboardItemView(
                        transactions: allTransactions.filter { selectedTransactions.contains($0.id) },
                        title: "Selection"
                    )
                    
                } else {
                    
                    let month = Date.currentMonth
                    let transactions = allTransactionsGrouppedByMonth
                        .first(where: { $0.month == month })?.transactions ?? []
                    
                    ComptaDetailDashboardItemView(
                        transactions: transactions,
                        title: month
                    )
                }
                
                Divider()
            }
            .padding(24)
        }
    }
}
