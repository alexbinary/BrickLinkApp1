
import SwiftUI



struct OrderDetailComptaView: View {
    
    
    @Environment(\.transactionStore)
    var transactionStore: TransactionStoreProtocol!
    
    @Environment(\.shippingStore)
    var shippingStore: ShippingStoreProtocol!
    
    @Environment(\.refundStore)
    var refundStore: RefundStoreProtocol!
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    @State var editType: TransactionType = .orderIncome
    @State var editDate: Date = Date()
    @State var editAmount: Float = 0
    @State var editFees: Float = 0
    @State var editPaymentMethod: PaymentMethod = .paypal
    @State var editComment: String = ""
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􁚛 Register transaction")
            
            HStack(alignment: .top, spacing: 24) {
                
                Form {
                    
                    Picker("Type", selection: $editType) {
                        
                        ForEach([TransactionType.orderIncome, .orderShipping, .orderRefund], id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField(
                        "Amount", value: $editAmount,
                        format: .currency(code: "EUR").presentation(.isoCode)
                    )
                    .onSubmit { self.registerTransaction() }
                    
                    TextField(
                        "Fees", value: $editFees,
                        format: .currency(code: "EUR").presentation(.isoCode)
                    )
                    .onSubmit { self.registerTransaction() }
                    
                    PaymentMethodPicker("Payment method", selection: $editPaymentMethod)
                    
                    DatePicker("Date", selection: $editDate)
                    
                    TextField("Comment", text: $editComment, axis: .vertical).lineLimit(3...5)
                    
                    Button("Register transaction") {
                        self.registerTransaction()
                    }
                    
                    Button("Validate without income transaction") {
                        transactionStore.validateOrderWithoutIncomeTransaction(order)
                    }
                    Button("Validate without shipping transaction") {
                        transactionStore.validateOrderWithoutShippingTransaction(order)
                    }
                    
                    VStack(alignment: .leading) {
                        
                        if let date = transactionStore.dateOrderValidatedWithoutIncomeTransaction(order) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("Validated without transaction on")
                                Text(date, format: .dateTime)
                            }
                        }
                        
                        if let date = transactionStore.dateOrderValidatedWithoutShippingTransaction(order) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("Validated without transaction on")
                                Text(date, format: .dateTime)
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    
                    if transactionStore.incomeTransactions(for: order).isEmpty {
                        
                        view(for: Transaction(
                            
                            date: order.date,
                            type: .orderIncome,
                            amount: order.grandTotal,
                            fees: editFees,
                            paymentMethod: .cb_iban,
                            comment: "",
                            orderRefIn: order.id
                            
                        ), title: {
                            
                            Text("􁇖 Suggested income transaction")
                                .font(.system(size: 12).bold())
                                .foregroundStyle(.secondary)
                        })
                        .padding(.bottom)
                    }
                    
                    if transactionStore.shippingTransactions(for: order).isEmpty,
                       let cost = shippingStore.confirmedShippingCost(for: order) {
                        
                        view(for: Transaction(
                            
                            date: editDate,
                            type: .orderShipping,
                            amount: cost,
                            fees: editFees,
                            paymentMethod: .cb_iban,
                            comment: "",
                            orderRefIn: order.id
                            
                        ), title: {
                            
                            Grid(alignment: .leading, verticalSpacing: 4) {
                                
                                GridRow(alignment: .firstTextBaseline) {
                                    
                                    Text("􁇖")
                                    Text("Suggested shipping transaction")
                                }
                                .font(.system(size: 12).bold())
                                .foregroundStyle(.secondary)
                             
                                GridRow(alignment: .firstTextBaseline) {
                                    
                                    Text("")
                                    
                                    HStack(alignment: .firstTextBaseline) {
                                        Text("Confirmed stamping:")
                                        if let stamping = shippingStore.confirmedStamping(for: order) {
                                            Text(stamping)
                                        }
                                    }
                                }
                                .font(.system(size: 12))
                            }
                        })
                        .padding(.bottom)
                    }
                    
                    if let amount = refundStore.refunds(for: order).last?.amount {
                        
                        view(for: Transaction(
                            
                            date: editDate,
                            type: .orderRefund,
                            amount: amount,
                            fees: editFees,
                            paymentMethod: .paypal,
                            comment: "",
                            orderRefIn: order.id
                            
                        ), title: {
                            
                            Grid(alignment: .leading, verticalSpacing: 4) {
                                
                                GridRow(alignment: .firstTextBaseline) {
                                    
                                    Text("􁇖")
                                    Text("Suggested refund transaction")
                                }
                                .font(.system(size: 12).bold())
                                .foregroundStyle(.secondary)
                             
                                GridRow(alignment: .firstTextBaseline) {
                                    
                                    Text("")
                                    
                                    HStack(alignment: .firstTextBaseline) {
                                        Text("Latest refund:")
                                        if let refund = refundStore.refunds(for: order).last {
                                            Text(abs(refund.amount), format: .currency(code: "EUR").presentation(.isoCode))
                                        }
                                    }
                                }
                                .font(.system(size: 12))
                            }
                        })
                        .padding(.bottom)
                    }
                }
            }
            
            Color.clear.fixedSize()
            
            TransactionListView(
                transactions:
                    transactionStore.incomeTransactions(for: order)
                    + transactionStore.shippingTransactions(for: order)
                    + transactionStore.refundTransactions(for: order),
                grouppedByMonth: false,
                selectedTransactions: .constant([])
            )
        }
        .onChange(of: order, initial: true) {
            
            self.editDate = Date()
            self.editPaymentMethod = .cb_iban
        }
    }
    
    
    @ViewBuilder
    func view<Content: View>(for transaction: Transaction, title: () -> Content) -> some View {
        
        VStack(alignment: .leading) {
            
            HStack(alignment: .firstTextBaseline) {
                
                AnyView(title())
                
                Spacer()
                
                Button("Accept") {
                    register(Transaction(
                        date: transaction.date,
                        createdAt: Date(),
                        type: transaction.type,
                        amount: transaction.amount,
                        fees: transaction.fees,
                        paymentMethod: transaction.paymentMethod,
                        comment: transaction.comment,
                        orderRefIn: transaction.orderRefIn
                    ))
                }
            }
                
            HStack {
                Grid(alignment: .leading, horizontalSpacing: 12) {
                    
                    GridRow(alignment: .firstTextBaseline) {
                        
                        Text("Amount")
                        Text("Fees")
                        Text("Payment method")
                        Text("Date")
                    }
                    .captionStyle()
                    
                    GridRow(alignment: .firstTextBaseline) {
                        
                        Text(abs(transaction.amount), format: .currency(code: "EUR").presentation(.isoCode))
                        if let fees = transaction.fees {
                            Text(abs(fees), format: .currency(code: "EUR").presentation(.isoCode))
                        } else {
                            Text("")
                        }
                        Text(transaction.paymentMethod.rawValue)
                        Text(transaction.date, format: .dateTime)
                    }
                }
                
                Spacer()
            }
            .padding()
            .roundedContainer(style: .secondary)
        }
    }
    

    func registerTransaction() {
        
        register(Transaction(
            date: editDate,
            createdAt: Date(),
            type: editType,
            amount: editAmount,
            fees: editFees,
            paymentMethod: editPaymentMethod,
            comment: editComment,
            orderRefIn: order.id
        ))
    }
    
    
    func register(_ transaction: Transaction) {
        
        transactionStore.register(transaction)
    }
}



#Preview {
    
    OrderDetailComptaView(.previewOrder1)
        .padding()
        .previewEnv()
}
