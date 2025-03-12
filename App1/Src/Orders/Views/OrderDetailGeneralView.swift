
import SwiftUI
import HTMLEntities



struct OrderDetailGeneralView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    
    let order: OrderDetails
    
    
    @State var incomeTransactionDate: Date = Date()
    @State var incomeTransactionAmount: Float = 0
    @State var incomeTransactionFees: Float = 0
    @State var incomeTransactionPaymentMethod: PaymentMethod = .paypal
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top, spacing: 96) {
                
                VStack(alignment: .leading) {
                    
                    Text("􂙡 Address").font(.caption).foregroundStyle(.secondary)
                    OrderAddressView(order)
                }
                .font(.title3)
                
                VStack(alignment: .leading) {
                    
                    HStack(spacing: 48) {
                        
                        VStack(alignment: .leading) {
                            
                            Text("􀖧 Grand total").captionSyle()
                            
                            Text(order.grandTotal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                .font(.title2)
                            
                            if order.dispCostCurrencyCode != order.costCurrencyCode {
                                Text(order.dispGrandTotal, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                                    .font(.title2)
                            }
                        }
                        
                        HStack {
                            
                            VStack(alignment: .leading) {
                                
                                Text("􀖧 Subtotal").captionSyle()
                                
                                Text(order.subTotal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                    .font(.title3)
                                
                                if order.dispCostCurrencyCode != order.costCurrencyCode {
                                    Text(order.dispSubTotal, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                                        .font(.title3)
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                
                                Text("􀖧 Shipping").captionSyle()
                                
                                Text(order.shippingCost, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                    .font(.title3)
                                
                                if order.dispCostCurrencyCode != order.costCurrencyCode {
                                    Text(order.dispShippingCost, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                                        .font(.title3)
                                }
                            }
                        }
                    }
                    .padding(.leading)
                    
                    Group {
                        
                        let transactions = app.incomeTransactions(forOrderWithId: order.id)
                        
                        if let date = app.dateOrderValidatedWithoutIncomeTransaction(orderId: order.id) {
                            
                            HStack {
                                Text("Validated without transaction on")
                                Text(date, format: .dateTime)
                            }
                            
                        } else if !transactions.isEmpty {
                            
                            HStack(alignment: .top, spacing: 12) {
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Amount").captionSyle()
                                    
                                    ForEach(transactions) { transaction in
                                        Text(transaction.amount, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                            .font(.title3)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Fees").captionSyle()
                                    
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
                                    
                                    Text("Method").captionSyle()
                                    
                                    ForEach(transactions) { transaction in
                                        Text(transaction.paymentMethod.rawValue)
                                            .font(.title3)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Date").captionSyle()
                                    
                                    ForEach(transactions) { transaction in
                                        Text(transaction.date, format: .dateTime)
                                            .font(.title3)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Validated").captionSyle()
                                    
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
                                .captionSyle()
                                
                                GridRow {
                                    
                                    TextField("Amount", value: $incomeTransactionAmount,
                                              format: .currency(code: "EUR").presentation(.isoCode)
                                    )
                                    .onSubmit {
                                        self.submitIncomeTransaction()
                                    }
                                    .frame(maxWidth: 70)
                                    
                                    TextField("Fees", value: $incomeTransactionFees,
                                              format: .currency(code: "EUR").presentation(.isoCode)
                                    )
                                    .onSubmit {
                                        self.submitIncomeTransaction()
                                    }
                                    .frame(maxWidth: 70)
                                    
                                    Picker("Payment method", selection: $incomeTransactionPaymentMethod) {
                                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                                            Text(method.rawValue).tag(method)
                                        }
                                    }
                                    .labelsHidden()
                                    .frame(maxWidth: 70)
                                    
                                    DatePicker("Date", selection: $incomeTransactionDate)
                                        .labelsHidden()
                                    
                                    Button("Register transaction") {
                                        self.submitIncomeTransaction()
                                    }
                                    Button("Validate without transaction") {
                                        self.app.validateOrderWithoutIncomeTransaction(orderId: order.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .roundedContainer(style: .secondary)
                }
            }
            
            Divider()
            
            let statuses: [OrderStatus] = [.paid, .packed, .shipped, .completed]
            
            HStack {
                ForEach(statuses, id: \.self) { status in
                    Button {
                        Task {
                            await app.updateOrderStatus(orderId: order.id, status: status)
                        }
                    } label: {
                        Text(status.rawValue)
                            .fontWeight(order.status == status ? .bold : .regular)
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
        
        app.registerTransaction(Transaction(
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
