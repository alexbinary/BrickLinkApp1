
import SwiftUI


struct ComptaContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    
    var body: some View {
        
        Table(appController.transactions) {
            
            TableColumn("Date") { transaction in
                Text(transaction.date, format: .dateTime)
            }
            TableColumn("Type") { transaction in
                Text(transaction.type)
            }
            TableColumn("Amount") { transaction in
                Text(transaction.amount, format: .currency(code: "EUR").presentation(.isoCode))
            }
            TableColumn("Payment") { transaction in
                Text(transaction.paymentMethod)
            }
            TableColumn("Order (in)") { transaction in
                Text(transaction.orderRefIn)
            }
            TableColumn("Created at") { transaction in
                Text(transaction.createdAt, format: .dateTime)
            }
            TableColumn("Comment") { transaction in
                Text(transaction.comment ?? "")
            }
            
        }
        .navigationTitle("Compta")
    }
}
