
import SwiftUI
import HTMLEntities



struct OrderGeneralView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let order: OrderDetails
    
    @State var incomeTransactionDate: Date = Date()
    @State var incomeTransactionAmount: Float = 0
    @State var incomeTransactionFees: Float = 0
    @State var incomeTransactionPaymentMethod: PaymentMethod = .paypal
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top, spacing: 96) {
                
                VStack(alignment: .leading) {
                    
                    Text("􂙡 Address")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(order.shippingAddressName)
                    Text(order.shippingAddress.htmlUnescape()).fixedSize(horizontal: false, vertical: true)
                    Text(order.shippingAddressCountryCode)
                }
                .font(.title3)
                
                VStack(alignment: .leading) {
                    
                    HStack(spacing: 48) {
                        
                        VStack(alignment: .leading) {
                            
                            Text("􀖧 Grand total")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(order.grandTotal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                .font(.title2)
                            
                            if order.dispCostCurrencyCode != order.costCurrencyCode {
                                Text(order.dispGrandTotal, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                                    .font(.title2)
                            }
                        }
                        
                        HStack {
                            
                            VStack(alignment: .leading) {
                                
                                Text("􀖧 Subtotal")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text(order.subTotal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                    .font(.title3)
                                
                                if order.dispCostCurrencyCode != order.costCurrencyCode {
                                    Text(order.dispSubTotal, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                                        .font(.title3)
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                
                                Text("􀖧 Shipping")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
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
                        
                        let transactions = appController.incomeTransactions(forOrderWithId: order.id)
                        
                        if let date = appController.dateOrderValidatedWithoutIncomeTransaction(orderId: order.id) {
                            
                            HStack {
                                
                                Text("Validated without transaction on")
                                Text(date, format: .dateTime)
                            }
                            
                        } else if !transactions.isEmpty {
                            
                            HStack(alignment: .top, spacing: 12) {
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Amount")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    ForEach(transactions) { transaction in
                                        Text(transaction.amount, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                            .font(.title3)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Fees")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
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
                                    
                                    Text("Method")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    ForEach(transactions) { transaction in
                                        Text(transaction.paymentMethod.rawValue)
                                            .font(.title3)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Date")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    ForEach(transactions) { transaction in
                                        Text(transaction.date, format: .dateTime)
                                            .font(.title3)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Validated")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
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
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("Fees")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("Method")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("Date")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
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
                                    
                                    Button {
                                        self.submitIncomeTransaction()
                                    } label: {
                                        Text("Register transaction")
                                    }
                                    Button {
                                        self.appController.validateOrderWithoutIncomeTransaction(orderId: order.id)
                                    } label: {
                                        Text("Validate without transaction")
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
                            await appController.updateOrderStatus(orderId: order.id, status: status)
                        }
                    } label: {
                        Text(status.rawValue)
                            .fontWeight(order.status == status ? .bold : .regular)
                    }
                }
            }
            
            Divider()
            
            Text("\(order.items) items in \(order.lots) lots - \(String(format: "%.0f", order.totalWeight))g")
            
            Table(appController.orderItems(forOrderWithId: order.id)) {
                
                TableColumn("Image") { item in
                    AsyncImage(url: appController.imageUrl(for: item))
                        .frame(minHeight: 60)
                }
                TableColumn("Condition", value: \.condition)
                TableColumn("Color") { item in
                    HStack {
                        appController.color(for: item).frame(width: 18, height: 18)
                        Text(appController.colorName(for: item))
                    }
                }
                TableColumn("Name") { item in
                    Text(item.name.htmlUnescape()).lineLimit(nil)
                }
                TableColumn("Ref", value: \.ref)
                TableColumn("Comment", value: \.comment)
                TableColumn("Quantity", value: \.quantity)
                TableColumn("PU") { item in
                    
                    if item.unitPriceFinal != item.unitPrice {
                        
                        Text(item.unitPrice, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                            .strikethrough()
                    }
                    Text(item.unitPriceFinal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                }
            }
        }
        .onAppear {
            
            self.setupFormStateFromOrder()
        }
        .onChange(of: order) {
            
            self.setupFormStateFromOrder()
        }
    }
    
    
    @ViewBuilder
    func checkStatus(_ status: Bool) -> some View {
        if status {
            Text("􀁣").foregroundStyle(green)
        } else {
            Text("􀀀").foregroundStyle(red)
        }
    }
    
    
    func setupFormStateFromOrder() {
        
        self.incomeTransactionDate = order.date
        self.incomeTransactionAmount = order.grandTotal
        self.incomeTransactionPaymentMethod = .paypal
    }
    
    
    func submitIncomeTransaction() {
        
        appController.registerTransaction(Transaction(
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
