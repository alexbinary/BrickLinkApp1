
import SwiftUI



struct OrderListItemView: View {
    
    
    @EnvironmentObject var app: AppController
    
    let orderId: OrderSummary.ID
    
    @State var hover: Bool = false
    
    
    var body: some View {
        
        if let order = app.orderSummary(forOrderWithId: orderId) {
            
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
                            
                            let items: [StatusItem] = statusItems
                            
                            let displayItems = items.limit(2)
                            
                            HStack(alignment: displayItems.count == 1 ? .bottom : .top, spacing: 24) {
                                
                                VStack(alignment: .leading) {
                                    Text("feedback").font(.caption).foregroundStyle(.secondary)
                                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                                        
                                        HStack {
                                            Text("Seller:")
                                            if let fb = app.orderFeedbacks(forOrderWithId: order.id).sellerFeedback() {
                                                FeedbackRatingView(feedback: fb).help(fb.comment)
                                            }
                                        }.frame(width: 100, alignment: .leading)
                                        
                                        HStack {
                                            Text("Buyer:")
                                            if let fb = app.orderFeedbacks(forOrderWithId: order.id).buyerFeedback() {
                                                FeedbackRatingView(feedback: fb).help(fb.comment)
                                            }
                                        }.frame(width: 100, alignment: .leading)
                                    }
                                }
                                
                                VStack(alignment: .trailing) {
                                    
                                    ForEach(displayItems, id: \.text) { item in
                                        
                                        HStack(spacing: 2) {
                                            
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
                                                .roundedContainer(style: .tag(baseColor: color))
                                            
                                            if let action = item.action {
                                                Button {
                                                    action()
                                                } label: {
                                                    Text("􀈟")
                                                }
                                            }
                                        }
                                    }
                                    
                                    if app.macroStatus(forOrderWithId: orderId) == .inTransit,
                                       let orderDetails = app.orderDetails(forOrderWithId: orderId),
                                       orderDetails.shippingMethodId.isOneOf(shippingMethodIds_LaPoste) {
                                        
                                        LaPosteTrackingView(status: app.laPosteTrackingStatus(forOrderWithId: orderId))
                                    }
                                }
                                .frame(width: 280, alignment: .trailing)
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
            .roundedContainer(
                backgroundColor: Color(nsColor: hover ? .tertiarySystemFill : .windowBackgroundColor),
                borderColor: statusColor.opacity(0.25)
            )
            .onHover { hover in
                self.hover = hover
            }
        }
    }
    
    
    var statusColor: Color {
        
        switch app.macroStatus(forOrderWithId: orderId) {
            
        case .validatePayment:
                .red
        case .pickAndPack:
                .red
        case .ship:
                .yellow
        case .inTransit:
                .orange
        case .inTransitFor30PlusDays:
                .orange
        case .received:
                .green
        case .giveFeedback:
                .green
        case .recentlyClosed:
                .green
        case .closed:
                .green
        }
    }
    
    
    var statusItems: [StatusItem] {
        
        guard let order = app.orderSummary(forOrderWithId: orderId) else { return [] }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        var items: [StatusItem] = []
        
        switch app.macroStatus(forOrderWithId: orderId) {
        
        case .validatePayment:
            
            if !app.orderChecklistPayment(orderId) {
                items.append(StatusItem(text: "Payment pending", status: .waitingOnExternalAction))
                
            } else if !app.orderChecklistIncomeTransaction(orderId) {
                items.append(StatusItem(text: "Register payment transaction", status: .actionRequired))
            }
            
        case .pickAndPack:
            
            if !app.orderChecklistPicking(orderId) {
                
                let picked = app.pickedItems(forOrderWithId: orderId).count
                let total = app.orderItems(forOrderWithId: orderId).count
                
                let percent = floor(Double(picked)/Double(total)*100)
                items.append(StatusItem(text: String(format: "%3.0f%% picked", percent), status: .actionRequired))
                
            } else if !app.orderChecklistVerification(orderId) {
                
                let verified = app.verifiedItems(forOrderWithId: orderId).count
                let total = app.orderItems(forOrderWithId: orderId).count
                
                let percent = floor(Double(verified)/Double(total)*100)
                items.append(StatusItem(text: String(format: "%3.0f%% verified", percent), status: .actionRequired))
                
            } else if !app.orderChecklistPacked(orderId) {
                items.append(StatusItem(text: "Not packed yet", status: .actionRequired))
            }
            
        case .ship:
            
            if !app.orderChecklistStamping(orderId) {
                items.append(StatusItem(text: "Stamping not validated", status: .actionRequired))
            }
            if !app.orderChecklistShippingTransaction(orderId) {
                items.append(StatusItem(text: "No shipping transaction", status: .actionRequired))
            }
            if !app.orderChecklistTrackingNo(orderId) {
                items.append(StatusItem(text: "Missing tracking no", status: .actionRequired))
            }
            
            if !app.orderChecklistShipped(orderId) && !app.orderChecklistDriveThru(orderId){
                items.append(StatusItem(text: "Ship and send Drive thru", status: .actionRequired, action: {
                    Task {
                        await app.updateOrderStatus(orderId: orderId, status: .shipped)
                        await app.sendDriveThru(orderId: orderId)
                    }
                }))
            } else {
                if !app.orderChecklistShipped(orderId) {
                    items.append(StatusItem(text: "Mark Shipped", status: .actionRequired))
                }
                if !app.orderChecklistDriveThru(orderId) {
                    items.append(StatusItem(text: "Send Drive thru", status: .actionRequired))
                }
            }
            
        case .inTransit, .inTransitFor30PlusDays:
            
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(StatusItem(text: "Shipped \(formattedDate)", status: .waitingOnExternalAction))
            
            if app.orderChecklistUnchangedFor30Days(orderId) {
                items.append(StatusItem(text: "Mark Completed and give feedback", status: .actionRequired, action: {
                    Task {
                        await app.updateOrderStatus(orderId: orderId, status: .completed)
                        await app.postPraiseOrderFeedback(orderId: order.id)
                    }
                }))
            }
            
        case .received:
                
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(StatusItem(text: "Received \(formattedDate)", status: .completed))
            
            items.append(StatusItem(text: "Waiting Completed or buyer feedback", status: .waitingOnExternalAction))
        
        case .giveFeedback:
                
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            if order.status == .completed {
                items.append(StatusItem(text: "Completed \(formattedDate)", status: .completed))
            } else {
                items.append(StatusItem(text: "Received \(formattedDate)", status: .completed))
            }
            
            items.append(StatusItem(text: "Give feedback", status: .actionRequired, action: {
                Task {
                    await app.postPraiseOrderFeedback(orderId: order.id)
                }
            }))
            
        case .recentlyClosed, .closed:
            
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(StatusItem(text: "Closed \(formattedDate)", status: .completed))
        }
        
        return items
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


struct StatusItem {
    
    let text: String
    let status: TodoStatus
    let action: (() -> Void)?
    
    init(text: String, status: TodoStatus, action: (() -> Void)? = nil) {
        self.text = text
        self.status = status
        self.action = action
    }
}
