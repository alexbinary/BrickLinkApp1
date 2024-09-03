
import SwiftUI
import Charts



struct ComptaDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
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
