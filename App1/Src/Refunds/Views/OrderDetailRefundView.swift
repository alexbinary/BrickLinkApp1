
import SwiftUI



struct OrderDetailRefundView: View {
    
    
    @Environment(RefundStore.self)
    var refundStore
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    @State var refundDate: Date = Date()
    @State var refundAmount: Float = 0
    @State var refundComment: String = ""
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􂈚 Refund")
               
            Form {
                TextField(
                    "Amount", value: $refundAmount,
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .onSubmit { self.submitRefund() }
                
                DatePicker("Date", selection: $refundDate)
                
                TextField("Comment", text: $refundComment, axis: .vertical).lineLimit(3...5)
                
                Button("Create refund") { self.submitRefund() }
            }
            
            Table(refundStore.refunds(for: order)) {
                
                TableColumn("Date") { refund in
                    Text(refund.date, format: .dateTime)
                }
                TableColumn("Amount") { refund in
                    Text(abs(refund.amount), format: .currency(code: "EUR").presentation(.isoCode))
                        .amountColor(.bad)
                }
                TableColumn("Comment") { refund in
                    Text(refund.comment)
                }
            }
            .frame(minHeight: 100)
        }
        .onChange(of: order, initial: true) {
            
            self.refundDate = Date()
            self.refundComment = ""
        }
    }
    
    
    func submitRefund() {
        
        refundStore.createRefund(OrderRefund(
            date: refundDate,
            amount: refundAmount,
            comment: refundComment,
            orderId: order.id
        ))
    }
}
