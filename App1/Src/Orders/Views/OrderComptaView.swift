
import SwiftUI



struct OrderComptaView: View {
    
    
    @EnvironmentObject var app: AppController
    
    let order: OrderDetails
    
    @State var incomeDate: Date = Date()
    @State var incomeAmount: Float = 0
    @State var incomeFees: Float = 0
    @State var incomePaymentMethod: PaymentMethod = .paypal
    @State var incomeComment: String = ""
    
    @State var shippingDate: Date = Date()
    @State var shippingAmount: Float = 0
    @State var shippingPaymentMethod: PaymentMethod = .cb_iban
    @State var shippingComment: String = ""
    
    @State var refundDate: Date = Date()
    @State var refundAmount: Float = 0
    @State var refundFees: Float = 0
    @State var refundPaymentMethod: PaymentMethod = .paypal
    @State var refundComment: String = ""
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􀗧 Income")
            
            Form {
                TextField("Amount", value: $incomeAmount,
                          format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit {
                    self.submitIncomeTransaction()
                }
                TextField("Fees", value: $incomeFees,
                          format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit {
                    self.submitIncomeTransaction()
                }
                Picker("Payment method", selection: $incomePaymentMethod) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                DatePicker("Date", selection: $incomeDate)
                TextField("Comment", text: $incomeComment, axis: .vertical)
                    .lineLimit(3...5)
                
                HStack {
                    Button {
                        self.submitIncomeTransaction()
                    } label: {
                        Text("Register transaction")
                    }
                    Button {
                        self.app.validateOrderWithoutIncomeTransaction(orderId: order.id)
                    } label: {
                        Text("Validate without transaction")
                    }
                    if let date = app.dateOrderValidatedWithoutIncomeTransaction(orderId: order.id) {
                        Text("Validated without transaction on")
                        Text(date, format: .dateTime)
                    }
                }
            }

            TransactionListView(
                transactions: app.transactions
                    .filter { $0.type == .orderIncome && $0.orderRefIn == order.id },
                grouppedByMonth: false,
                selectedTransactions: .constant([])
            )
            .frame(minHeight: 100)
            
            Divider()
            
            HeaderTitleView(label: "􀐚 Shipping")
               
            HStack {
                Text("Confirmed affranchissment:")
                if let confirmedMethod = app.stamping(forOrderWithId: order.id) {
                    Text(confirmedMethod)
                }
            }
            
            Form {
                TextField("Amount", value: $shippingAmount,
                          format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit {
                    self.submitShippingTransaction()
                }
                Picker("Payment method", selection: $shippingPaymentMethod) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                DatePicker("Date", selection: $shippingDate)
                TextField("Comment", text: $shippingComment, axis: .vertical)
                    .lineLimit(3...5)
                
                HStack {
                    Button {
                        self.submitShippingTransaction()
                    } label: {
                        Text("Register transaction")
                    }
                    Button {
                        self.app.validateOrderWithoutShippingTransaction(orderId: order.id)
                    } label: {
                        Text("Validate without transaction")
                    }
                    if let date = app.dateOrderValidatedWithoutShippingTransaction(orderId: order.id) {
                        Text("Validated without transaction on")
                        Text(date, format: .dateTime)
                    }
                }
            }
            
            TransactionListView(
                transactions: app.transactions
                    .filter { $0.type == .orderShipping && $0.orderRefIn == order.id },
                grouppedByMonth: false,
                selectedTransactions: .constant([])
            )
            .frame(minHeight: 100)
            
            Divider()
            
            HeaderTitleView(label: "􂈚 Refund")
            
            HStack {
                Text("Latest refund:")
                if let refund = app.refunds(for: order).last {
                    Text(abs(refund.amount), format: .currency(code: "EUR").presentation(.isoCode))
                }
            }
               
            Form {
                TextField("Amount", value: $refundAmount,
                          format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit {
                    self.submitRefundTransaction()
                }
                TextField("Fees", value: $refundFees,
                          format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit {
                    self.submitRefundTransaction()
                }
                Picker("Payment method", selection: $refundPaymentMethod) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                DatePicker("Date", selection: $refundDate)
                TextField("Comment", text: $refundComment, axis: .vertical)
                    .lineLimit(3...5)
                
                HStack {
                    Button {
                        self.submitRefundTransaction()
                    } label: {
                        Text("Register transaction")
                    }
                }
            }
            
            TransactionListView(
                transactions: app.transactions
                    .filter { $0.type == .orderRefund && $0.orderRefIn == order.id },
                grouppedByMonth: false,
                selectedTransactions: .constant([])
            )
            .frame(minHeight: 100)
        }
        .onAppear {
            
            self.setupFormStateFromOrder()
        }
        .onChange(of: order) {
            
            self.setupFormStateFromOrder()
        }
    }
    
    
    func setupFormStateFromOrder() {
        
        self.incomeDate = order.date
        self.incomeAmount = order.grandTotal
        self.incomePaymentMethod = .paypal
        self.incomeComment = ""

        self.shippingDate = Date()
        self.shippingAmount = app.shippingCost(forOrderWithId: order.id) ?? 0
        self.shippingPaymentMethod = .cb_iban
        self.shippingComment = ""
        
        self.refundDate = Date()
        self.refundAmount = app.refunds(for: order).last?.amount ?? 0
        self.refundPaymentMethod = .paypal
        self.refundComment = ""
    }
    
    
    func submitIncomeTransaction() {
        
        app.registerTransaction(Transaction(
            date: incomeDate,
            createdAt: Date(),
            type: .orderIncome,
            amount: incomeAmount,
            fees: incomeFees,
            paymentMethod: incomePaymentMethod,
            comment: incomeComment,
            orderRefIn: order.id
        ))
    }
    
    
    func submitShippingTransaction() {
     
        app.registerTransaction(Transaction(
            date: shippingDate,
            createdAt: Date(),
            type: .orderShipping,
            amount: shippingAmount,
            fees: nil,
            paymentMethod: shippingPaymentMethod,
            comment: shippingComment,
            orderRefIn: order.id
        ))
    }
    
    
    func submitRefundTransaction() {
     
        app.registerTransaction(Transaction(
            date: refundDate,
            createdAt: Date(),
            type: .orderRefund,
            amount: refundAmount,
            fees: refundFees,
            paymentMethod: refundPaymentMethod,
            comment: refundComment,
            orderRefIn: order.id
        ))
    }
}
