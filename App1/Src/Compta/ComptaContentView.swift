
import SwiftUI


struct ComptaContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
    var body: some View {
        
        TransactionListView(transactions: appController.transactions)
            .navigationTitle("Compta")
    }
}
