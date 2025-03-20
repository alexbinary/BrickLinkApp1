
import SwiftUI



struct OrderDetailComptaView: View {
    
    
    @Environment(TransactionController.self)
    var transactionController
    
    @Environment(ShippingStore.self)
    var shippingStore
    
    @Environment(RefundStore.self)
    var refundStore
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
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
                TextField(
                    "Amount", value: $incomeAmount,
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit { self.submitIncomeTransaction() }
                
                TextField(
                    "Fees", value: $incomeFees,
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit { self.submitIncomeTransaction() }
                
                PaymentMethodPicker("Payment method", selection: $incomePaymentMethod)
                
                DatePicker("Date", selection: $incomeDate)
                
                TextField("Comment", text: $incomeComment, axis: .vertical).lineLimit(3...5)
                
                HStack {
                    Button("Register transaction") {
                        self.submitIncomeTransaction()
                    }
                    Button("Validate without transaction") {
                        transactionController.validateOrderWithoutIncomeTransaction(orderId: order.id)
                    }
                    if let date = transactionController.dateOrderValidatedWithoutIncomeTransaction(orderId: order.id) {
                        Text("Validated without transaction on")
                        Text(date, format: .dateTime)
                    }
                }
            }

            TransactionListView(
                transactions: transactionController.incomeTransactions(forOrderWithId: order.id),
                grouppedByMonth: false,
                selectedTransactions: .constant([])
            )
            .frame(minHeight: 100)
            
            Divider()
            
            HeaderTitleView(label: "􀐚 Shipping")
               
            HStack {
                Text("Confirmed stamping:")
                if let stamping = shippingStore.stamping(forOrderWithId: order.id) {
                    Text(stamping)
                }
            }
            
            Form {
                TextField(
                    "Amount", value: $shippingAmount,
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit { self.submitShippingTransaction() }
                
                PaymentMethodPicker("Payment method", selection: $shippingPaymentMethod)
                
                DatePicker("Date", selection: $shippingDate)
                
                TextField("Comment", text: $shippingComment, axis: .vertical).lineLimit(3...5)
                
                HStack {
                    Button("Register transaction") {
                        self.submitShippingTransaction()
                    }
                    Button("Validate without transaction") {
                        transactionController.validateOrderWithoutShippingTransaction(orderId: order.id)
                    }
                    if let date = transactionController.dateOrderValidatedWithoutShippingTransaction(orderId: order.id) {
                        Text("Validated without transaction on")
                        Text(date, format: .dateTime)
                    }
                }
            }
            
            TransactionListView(
                transactions: transactionController.shippingTransactions(forOrderWithId: order.id),
                grouppedByMonth: false,
                selectedTransactions: .constant([])
            )
            .frame(minHeight: 100)
            
            Divider()
            
            HeaderTitleView(label: "􂈚 Refund")
            
            HStack {
                Text("Latest refund:")
                if let refund = refundStore.refunds(for: order).last {
                    Text(abs(refund.amount), format: .currency(code: "EUR").presentation(.isoCode))
                }
            }
               
            Form {
                TextField(
                    "Amount", value: $refundAmount,
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit { self.submitRefundTransaction() }

                TextField(
                    "Fees", value: $refundFees,
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit { self.submitRefundTransaction() }
                
                PaymentMethodPicker("Payment method", selection: $refundPaymentMethod)
                
                DatePicker("Date", selection: $refundDate)
                
                TextField("Comment", text: $refundComment, axis: .vertical).lineLimit(3...5)
                
                Button("Register transaction") {
                    self.submitRefundTransaction()
                }
            }
            
            TransactionListView(
                transactions: transactionController.refundTransactions(forOrderWithId: order.id),
                grouppedByMonth: false,
                selectedTransactions: .constant([])
            )
            .frame(minHeight: 100)
        }
        .onChange(of: order, initial: true) {
            
            self.incomeDate = order.date
            self.incomeAmount = order.grandTotal
            self.incomePaymentMethod = .paypal
            self.incomeComment = ""

            self.shippingDate = Date()
            self.shippingAmount = shippingStore.shippingCost(forOrderWithId: order.id) ?? 0
            self.shippingPaymentMethod = .cb_iban
            self.shippingComment = ""
            
            self.refundDate = Date()
            self.refundAmount = refundStore.refunds(for: order).last?.amount ?? 0
            self.refundPaymentMethod = .paypal
            self.refundComment = ""
        }
    }
    

    func submitIncomeTransaction() {
        
        transactionController.register(Transaction(
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
     
        transactionController.register(Transaction(
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
     
        transactionController.register(Transaction(
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



#Preview {
    
    let controllers = AppController.createControllers()
    let transactionController = controllers.transactionController
    let shippingStore = controllers.shippingStore
    let refundStore = controllers.refundStore

    let orderStore = controllers.orderStore
    let order = orderStore.orderDetails.first!
    
    OrderDetailComptaView(order)
        .environment(transactionController)
        .environment(shippingStore)
        .environment(refundStore)
}
