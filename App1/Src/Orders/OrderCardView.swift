
import SwiftUI



struct OrderCardView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderSummary.ID
    
    
    var body: some View {
        
        if let order = appController.orderSummary(forOrderWithId: orderId) {
            
            HStack {
                
                VStack(alignment: .trailing) {
                    
                    HStack(alignment: .top, spacing: 16) {
                        
                        VStack(alignment: .leading) {
                            
                            Grid(alignment: .leading, verticalSpacing: 0) {
                                
                                GridRow {
                                    Text("order").cardCaption()
                                    Text("placed").cardCaption()
                                    
                                }
                                
                                GridRow {
                                    Link(destination: URL(string: "https://www.bricklink.com/orderDetail.asp?ID=\(order.id)#/")!) {
                                        Text(order.id).font(.title2)
                                    }
                                    .monospacedDigit()
                                    Text(order.date, format: .dateTime)
                                        .frame(width: 150, alignment: .leading)
                                        .monospacedDigit()
                                }
                            }
                            
                            Text("")
                            
                            Grid(alignment: .leading) {
                                
                                GridRow {
                                    Text("􀉩").foregroundStyle(.secondary).gridColumnAlignment(.center)
                                    Text(order.buyer)
                                }
                                
                                GridRow {
                                    Text("􀍩").foregroundStyle(.secondary).gridColumnAlignment(.center)
                                    
                                    HStack {
                                        Text("\(order.items) (\(order.lots))")
                                            .frame(width: 75, alignment: .leading)
                                        HStack {
                                            Text("􀖧").foregroundStyle(.secondary)
                                            Text(order.grandTotal, format: .currency(code: "EUR").presentation(.isoCode))
                                                .monospacedDigit()
                                        }
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            
                            Grid(alignment: .leading, verticalSpacing: 0) {
                                
                                GridRow {
                                    Text("status").cardCaption()
                                    Text("changed").cardCaption()
                                }
                                GridRow {
                                    Text(order.status.rawValue).font(.title3)
                                    Text(order.dateStatusChanged, format: .dateTime)
                                        .monospacedDigit()
                                }
                                    
                            }
                            .frame(width: 274, alignment: .trailing)
                            
                            Text("")
                            
                            let items = {
                                
                                var items = [String]()
                                
                                if !appController.orderChecklistPayment(orderId) {
                                    items.append("Payment received")
                                }
                                if !appController.orderChecklistIncomeTransaction(orderId) {
                                    items.append("Register transaction")
                                }
                                if !appController.orderChecklistPicking(orderId) {
                                    items.append("Pick items")
                                }
                                if !appController.orderChecklistVerification(orderId) {
                                    items.append("Verify items")
                                }
                                if !appController.orderChecklistPacked(orderId) {
                                    items.append("Pack order")
                                }
                                if !appController.orderChecklistShipped(orderId) {
                                    items.append("Mark Shipped")
                                }
                                if !appController.orderChecklistTrackingNo(orderId) {
                                    items.append("Input tracking no")
                                }
                                if !appController.orderChecklistDriveThru(orderId) {
                                    items.append("Send drive thru")
                                }
                                if !appController.orderChecklistAffranchissement(orderId) {
                                    items.append("Validate stamping")
                                }
                                if !appController.orderChecklistShippingTransaction(orderId) {
                                    items.append("Register transaction")
                                }
                                if !appController.orderChecklistReceived(orderId) {
                                    items.append("Received or Completed")
                                }
                                if !appController.orderChecklistSellerFeedback(orderId) {
                                    items.append("Give feedback")
                                }
                                if !appController.orderChecklistUnchangedFor30Days(orderId) {
                                    items.append("Inactive for 30 days")
                                }
                                
                                return items
                            }()
                            
                            let displayItems = items.limit(2)
                            
                            HStack(alignment: displayItems.count == 1 ? .bottom : .top, spacing: 24) {
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Buyer:")
                                        if let rating = appController.orderFeedbacks(forOrderWithId: order.id).buyerFeedback()?.rating {
                                            if rating == 0 {
                                                Text("􀉿")
                                            } else if rating == 2 {
                                                Text("􀊁")
                                            } else {
                                                Text("Neutral")
                                            }
                                        }
                                    }
                                    HStack {
                                        Text("Seller:")
                                        if let rating = appController.orderFeedbacks(forOrderWithId: order.id).sellerFeedback()?.rating {
                                            if rating == 0 {
                                                Text("􀉿")
                                            } else if rating == 2 {
                                                Text("􀊁")
                                            } else {
                                                Text("Neutral")
                                            }
                                        }
                                    }
                                }
                                .frame(width: 100, alignment: .leading)
                                
                                VStack(alignment: .trailing) {
                                    
                                    ForEach(displayItems, id: \.self) { item in
                                        Text(item)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(.red.opacity(0.1))
                                            .cornerRadius(3)
                                    }
                                }
                                .frame(width: 150, alignment: .trailing)
                            }
                        }
                    }
                }
                
                Text("")
                
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(nsColor: .quaternarySystemFill))
            .border(Color(nsColor: .tertiarySystemFill))
            .cornerRadius(6)
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
}



extension View {
    
    
    @ViewBuilder func cardCaption() -> some View {
        
        self.font(.caption).foregroundStyle(.secondary)
    }
}
