
import SwiftUI


struct TransactionListView: View {
    
    
    let transactions: [Transaction]
    var grouppedByMonth = true
    
    
    @Binding var selectedTransactions: Set<Transaction.ID>
    
    
    var body: some View {
        
        Table(of: Transaction.self, selection: $selectedTransactions) {
            
            TableColumn("Date") { transaction in
                Text(transaction.date, format: .dateTime)
            }
            TableColumn("Type") { transaction in
                Text(transaction.type.rawValue)
            }
            TableColumn("Amount") { transaction in
                Text(abs(transaction.amount), format: .currency(code: "EUR").presentation(.isoCode))
                    .signedAmountColor(transaction.amount)
            }
            TableColumn("Payment") { transaction in
                Text(transaction.paymentMethod.rawValue)
            }
            TableColumn("Order (in)") { transaction in
                Text(transaction.orderRefIn)
            }
            TableColumn("Created at") { transaction in
                Text(transaction.createdAt, format: .dateTime)
            }
            TableColumn("Comment") { transaction in
                Text(transaction.comment)
            }
            
        } rows : {
            
            let transactions = transactions.sorted { $0.date > $1.date }
            
            if grouppedByMonth {
                
                ForEach(transactions.grouppedByMonth, id: \.month) { item in
                    
                    Section(item.month) {
                        
                        ForEach(item.transactions) { TableRow($0) }
                    }
                }
                
            } else {
                
                ForEach(transactions) { TableRow($0) }
            }
        }
    }
}
