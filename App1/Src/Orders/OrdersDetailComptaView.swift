
import SwiftUI



struct OrdersDetailComptaView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let order: Order
    
    @State var incomeDate: Date = Date()
    @State var incomeAmount: Float = 0
    @State var incomePaymentMethod: PaymentMethod = .paypal
    @State var incomeComment: String = ""
    
    @State var shippingDate: Date = Date()
    @State var shippingAmount: Float = 0
    @State var shippingPaymentMethod: PaymentMethod = .cb_iban
    @State var shippingComment: String = ""
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􀗧 Income")
            
            Form {
                TextField("Amount", value: $incomeAmount,
                          format: .currency(code: "EUR").presentation(.isoCode)
                )
                Picker("Payment method", selection: $incomePaymentMethod) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                DatePicker("Date", selection: $incomeDate)
                TextField("Comment", text: $incomeComment, axis: .vertical)
                    .lineLimit(3...5)
                
                Button {
                    appController.registerTransaction(Transaction(
                        date: incomeDate,
                        createdAt: Date(),
                        type: .orderIncome,
                        amount: incomeAmount,
                        paymentMethod: incomePaymentMethod,
                        comment: incomeComment,
                        orderRefIn: order.id
                    ))
                } label: {
                    Text("Register transaction")
                }
            }

            TransactionListView(
                transactions: appController.transactions
                    .filter { $0.type == .orderIncome && $0.orderRefIn == order.id },
                grouppedByMonth: false,
                selectedTransactions: .constant([])
            )
            .frame(minHeight: 100)
            
            Divider()
            
            HeaderTitleView(label: "􀐚 Shipping")
               
            HStack {
                Text("Confirmed affranchissment:")
                if let confirmedMethod = appController.affranchissement(forOrderWithId: order.id) {
                    Text(confirmedMethod)
                }
            }
            
            Form {
                TextField("Amount", value: $shippingAmount,
                          format: .currency(code: "EUR").presentation(.isoCode)
                )
                Picker("Payment method", selection: $shippingPaymentMethod) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                DatePicker("Date", selection: $shippingDate)
                TextField("Comment", text: $shippingComment, axis: .vertical)
                    .lineLimit(3...5)
                
                Button {
                    appController.registerTransaction(Transaction(
                        date: shippingDate,
                        createdAt: Date(),
                        type: .orderShipping,
                        amount: -shippingAmount,
                        paymentMethod: shippingPaymentMethod,
                        comment: shippingComment,
                        orderRefIn: order.id
                    ))
                } label: {
                    Text("Register transaction")
                }
            }
            
            TransactionListView(
                transactions: appController.transactions
                    .filter { $0.type == .orderShipping && $0.orderRefIn == order.id },
                grouppedByMonth: false,
                selectedTransactions: .constant([])
            )
            .frame(minHeight: 100)
            
            Divider()
        }
        .onAppear {
            
            self.incomeDate = order.date
            self.incomeAmount = order.grandTotal
            self.incomePaymentMethod = .paypal
            self.incomeComment = ""

            self.shippingDate = Date()
            self.shippingAmount = appController.shippingCost(forOrderWithId: order.id) ?? 0
            self.shippingPaymentMethod = .cb_iban
            self.shippingComment = ""
        }
    }
}
