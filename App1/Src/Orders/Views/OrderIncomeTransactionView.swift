
import SwiftUI



struct OrderIncomeTransactionView: View {

    
    @Environment(TransactionController.self)
    var transactionController
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    @State var incomeTransactionDate: Date = Date()
    @State var incomeTransactionAmount: Float = 0
    @State var incomeTransactionFees: Float = 0
    @State var incomeTransactionPaymentMethod: PaymentMethod = .paypal
    
    
    var body: some View {

        Group {
            
            let transactions = transactionController.incomeTransactions(forOrderWithId: order.id)
            
            if let date = transactionController.dateOrderValidatedWithoutIncomeTransaction(orderId: order.id) {
                
                HStack {
                    Text("Validated without transaction on")
                    Text(date, format: .dateTime)
                }
                
            } else if !transactions.isEmpty {
                
                HStack(alignment: .top, spacing: 12) {
                    
                    VStack(alignment: .leading) {
                        
                        Text("Amount").captionStyle()
                        
                        ForEach(transactions) { transaction in
                            Text(transaction.amount, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                .font(.title3)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text("Fees").captionStyle()
                        
                        ForEach(transactions) { transaction in
                            if let fees = transaction.fees, fees != 0 {
                                Text(fees, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                    .font(.title3)
                            } else {
                                Text("-")
                                    .font(.title3)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text("Method").captionStyle()
                        
                        ForEach(transactions) { transaction in
                            Text(transaction.paymentMethod.rawValue)
                                .font(.title3)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text("Date").captionStyle()
                        
                        ForEach(transactions) { transaction in
                            Text(transaction.date, format: .dateTime)
                                .font(.title3)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text("Validated").captionStyle()
                        
                        ForEach(transactions) { transaction in
                            Text(transaction.createdAt, format: .dateTime)
                                .font(.title3)
                        }
                    }
                }
                
            } else {
                
                Grid(alignment: .leading) {
                    
                    GridRow {
                        Text("Amount")
                        Text("Fees")
                        Text("Method")
                        Text("Date")
                    }
                    .captionStyle()
                    
                    GridRow {
                        
                        TextField(
                            "Amount", value: $incomeTransactionAmount,
                            format: .currency(code: "EUR").presentation(.isoCode)
                        )
                        .onSubmit { self.submitIncomeTransaction() }
                        .frame(maxWidth: 70)
                        
                        TextField(
                            "Fees", value: $incomeTransactionFees,
                            format: .currency(code: "EUR").presentation(.isoCode)
                        )
                        .onSubmit { self.submitIncomeTransaction() }
                        .frame(maxWidth: 70)
                        
                        PaymentMethodPicker("Payment method", selection: $incomeTransactionPaymentMethod)
                            .labelsHidden()
                            .frame(maxWidth: 70)
                        
                        DatePicker("Date", selection: $incomeTransactionDate)
                            .labelsHidden()
                        
                        Button("Register transaction") {
                            self.submitIncomeTransaction()
                        }
                        Button("Validate without transaction") {
                            transactionController.validateOrderWithoutIncomeTransaction(orderId: order.id)
                        }
                    }
                }
            }
        }
        .onChange(of: order, initial: true) {
            
            self.incomeTransactionDate = order.date
            self.incomeTransactionAmount = order.grandTotal
            self.incomeTransactionPaymentMethod = .paypal
        }
    }
    
    
    func submitIncomeTransaction() {
        
        transactionController.register(Transaction(
            date: incomeTransactionDate,
            createdAt: Date(),
            type: .orderIncome,
            amount: incomeTransactionAmount,
            fees: incomeTransactionFees,
            paymentMethod: incomeTransactionPaymentMethod,
            comment: "",
            orderRefIn: order.id
        ))
    }
}



#Preview {
    
    let controllers = AppController.createControllers()
    
    let transactionController = controllers.transaction
    
    let orderController = controllers.order
    let order = orderController.orderDetails.first!
    
    OrderIncomeTransactionView(order)
        .environment(transactionController)
}
