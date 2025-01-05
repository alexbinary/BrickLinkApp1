
import SwiftUI



struct OrderListItemView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderSummary.ID
    
    @State var hover: Bool = false
    
    
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
                            
                            Text("")
                            
                            let items: [(text: String, status: TodoStatus)] = {
                                
                                var items: [(text: String, status: TodoStatus)] = []
                                
                                switch appController.orderBusinessStatus(orderId) {
                                case .paymentPending:
                                    
                                    if !appController.orderChecklistPayment(orderId) {
                                        items.append((text: "Payment pending", status: .waitingOnExternalAction))
                                    }
                                    
                                case .validatePayment:
                                    
                                    if !appController.orderChecklistIncomeTransaction(orderId) {
                                        items.append((text: "No payment transaction", status: .actionRequired))
                                    }
                                    
                                case .pickAndPack:
                                    
                                    if !appController.orderChecklistPicking(orderId) {
                                        items.append((text: "Items not picked", status: .actionRequired))
                                    }
                                    if !appController.orderChecklistVerification(orderId) {
                                        items.append((text: "Items not verified", status: .actionRequired))
                                    }
                                    if !appController.orderChecklistPacked(orderId) {
                                        items.append((text: "Not packed", status: .actionRequired))
                                    }
                                    
                                case .ship:
                                    
                                    if !appController.orderChecklistStamping(orderId) {
                                        items.append((text: "Stamping not validated", status: .actionRequired))
                                    }
                                    if !appController.orderChecklistShippingTransaction(orderId) {
                                        items.append((text: "No shipping transaction", status: .actionRequired))
                                    }
                                    if !appController.orderChecklistTrackingNo(orderId) {
                                        items.append((text: "Missing tracking no", status: .actionRequired))
                                    }
                                    if !appController.orderChecklistShipped(orderId) {
                                        items.append((text: "Not marked Shipped", status: .actionRequired))
                                    }
                                    if !appController.orderChecklistDriveThru(orderId) {
                                        items.append((text: "Drive thru not sent", status: .actionRequired))
                                    }
                                    
                                case .inTransit:
                                    
                                    if !appController.orderChecklistReceived(orderId) {
                                        items.append((text: "Waiting for Received/Completed", status: .waitingOnExternalAction))
                                    }
                                    
                                case .giveFeedback:
                                    
                                    if !appController.orderChecklistSellerFeedback(orderId) {
                                        items.append((text: "No seller feedback", status: .actionRequired))
                                    }
                                    
                                case .done:
                                    
                                    if !appController.orderChecklistUnchangedFor30Days(orderId) {
                                        items.append((text: "Active in the last 30 days", status: .waitingOnExternalAction))
                                    }
                                    
                                case .closed:
                                    
                                    items.append((text: "Closed", status: .completed))
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
                                    
                                    ForEach(displayItems, id: \.text) { item in
                                        
                                        let color: Color = {
                                            switch item.status {
                                            case .actionRequired:
                                                    .red
                                            case .waitingOnExternalAction:
                                                    .yellow
                                            case .completed:
                                                    .green
                                            }
                                        }()
                                        
                                        Text(item.text)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(color.gradient.opacity(0.1))
                                            .cornerRadius(3)
                                    }
                                }
                                .frame(width: 220, alignment: .trailing)
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
            .background(Color(nsColor: hover ? .tertiarySystemFill : .windowBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(statusColor.opacity(0.25), lineWidth: 1)
            )
            .onHover { hover in
                self.hover = hover
            }
        }
    }
    
    
    var statusColor: Color {
        
        switch appController.orderBusinessStatus(orderId) {
            
        case .paymentPending:
                .red
        case .validatePayment:
                .red
        case .pickAndPack:
                .red
        case .ship:
                .yellow
        case .inTransit:
                .orange
        case .giveFeedback:
                .green
        case .done:
                .green
        case .closed:
                .green
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


enum TodoStatus {
    
    case actionRequired
    case waitingOnExternalAction
    case completed
}
