
import SwiftUI



struct OrdersMainListItem: View {
    
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    @Environment(\.pickingStore)
    var pickingStore: PickingStoreProtocol!
    
    @Environment(\.feedbackStore)
    var feedbackStore: FeedbackStoreProtocol!
    
    
    let order: Order
    var macroStatus: OrderMacroStatus { orderStore.macroStatus(for: order) }
    
    
    @State var hover: Bool = false
    
    
    var body: some View {
            
        HStack(spacing: 12) {
            
            HStack(alignment: .top, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 18) {
                    
                    Grid(alignment: .leading, verticalSpacing: 0) {
                        
                        GridRow {
                            HStack {
                                Text("order")
                                if orderStore.isLoadingDetails(for: order) {
                                    ProgressView()
                                        .controlSize(.mini)
                                }
                            }
                            .captionStyle()
                            Text("placed").captionStyle()
                        }
                        
                        GridRow {
                            OrderLink(order) { Text(order.id) }
                                .font(.title2)
                                .monospacedDigit()
                            Text(order.date, format: .dateTime)
                                .frame(width: 150, alignment: .leading)
                                .monospacedDigit()
                        }
                    }
                    
                    Grid(alignment: .leading, verticalSpacing: 4) {
                        
                        GridRow {
                            Text("􀉩").foregroundStyle(.secondary).gridColumnAlignment(.center)
                            Text(order.buyer).gridCellColumns(3)
                        }
                        
                        GridRow {
                            Text("􀍩").foregroundStyle(.secondary).gridColumnAlignment(.center)
                            Text("\(order.items) (\(order.lots))").frame(width: 75, alignment: .leading)
                            
                            Text("􀖧").foregroundStyle(.secondary)
                            Text(order.grandTotal, format: .currency(code: "EUR").presentation(.isoCode)).monospacedDigit()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 18) {
                    
                    Grid(alignment: .leading, verticalSpacing: 0) {
                        
                        GridRow {
                            Text("status").captionStyle()
                            Text("changed").captionStyle()
                        }
                        GridRow {
                            Text(order.status.rawValue).font(.title3)
                            Text(order.dateStatusChanged, format: .dateTime).monospacedDigit()
                        }
                    }
                    
                    let tags = statusTags.limit(2)
                    
                    HStack(alignment: tags.count == 1 ? .bottom : .top, spacing: 24) {
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("feedback")
                                if feedbackStore.isLoadingFeedbacks(for: order) {
                                    ProgressView()
                                        .controlSize(.mini)
                                }
                            }
                            .captionStyle()
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                
                                HStack {
                                    Text("Seller:")
                                    if let feedback = feedbackStore.sellerFeedback(for: order) {
                                        FeedbackRatingView(feedback)
                                    }
                                }.frame(width: 100, alignment: .leading)
                                
                                HStack {
                                    Text("Buyer:")
                                    if let feedback = feedbackStore.buyerFeedback(for: order) {
                                        FeedbackRatingView(feedback)
                                    }
                                }.frame(width: 100, alignment: .leading)
                            }
                        }
                        
                        VStack(alignment: .trailing) {
                            
                            ForEach(tags) { tagView($0) }
                            
                            if macroStatus == .inTransit, let orderDetails = orderStore.details(for: order) {
                                
                                if orderDetails.shipsWithLaPoste {
                                    
                                    LaPosteTrackingStatusIndicator(order: order)
                                    
                                } else if orderDetails.shipsWithMondialRelay {
                                    
                                    Text("Mondial Relay")
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .roundedContainer(style: .tag(baseColor: .yellow))
                                }
                            }
                        }
                        .frame(width: 280, alignment: .trailing)
                    }
                }
            }
            
            DisclosureIndicator()
        }
        .padding()
        .roundedContainer(
            fill: hover ? .tertiarySystemFill : .windowBackgroundColor,
            stroke: statusColor.opacity(0.25)
        )
        .onHover { self.hover = $0 }
    }
    
    
    @ViewBuilder
    func tagView(_ tag: OrderStatusTag) -> some View {
        
        HStack(spacing: 2) {
            
            Text(tag.text)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .roundedContainer(style: .tag(baseColor: tag.status.color))
            
            if let action = tag.action {
                Button("􀈟") { action() }
            }
        }
    }
    
    
    var statusColor: Color {
        
        switch macroStatus {
            
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
        case .closedByBuyer:
                .green
        case .recentlyClosed:
                .green
        case .closed:
                .green
        }
    }
    
    
    var statusTags: [OrderStatusTag] {
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        var items: [OrderStatusTag] = []
        
        switch macroStatus {
        
        case .validatePayment:
            
            if !orderStore.order(order, validates: .payment) {
                items.append(OrderStatusTag(text: "Payment pending", status: .waitingOnExternalAction))
                
            } else if !orderStore.order(order, validates: .incomeTransaction) {
                items.append(OrderStatusTag(text: "Register payment transaction", status: .actionRequired))
            }
            
        case .pickAndPack:
            
            if !orderStore.order(order, validates: .picking) {
                
                let progress = pickingStore.pickingProgress(for: order)
                let text = progress == 0% ? "Start picking" : "\(progress) picked"
                items.append(OrderStatusTag(text: text, status: .actionRequired))
                
            } else if !orderStore.order(order, validates: .verification) {
                
                let progress = pickingStore.pickingVerificationProgress(for: order)
                let text = progress == 0% ? "Start verification" : "\(progress) verified"
                items.append(OrderStatusTag(text: text, status: .actionRequired))
                
            } else if !orderStore.order(order, validates: .packed) {
                items.append(OrderStatusTag(text: "Not packed yet", status: .actionRequired))
            }
            
        case .ship:
            
            if !orderStore.order(order, validates: .stamping) {
                items.append(OrderStatusTag(text: "Stamping not validated", status: .actionRequired))
            }
            if !orderStore.order(order, validates: .shippingTransaction) {
                items.append(OrderStatusTag(text: "No shipping transaction", status: .actionRequired))
            }
            if !orderStore.order(order, validates: .trackingNo) {
                items.append(OrderStatusTag(text: "Missing tracking no", status: .actionRequired))
            }
            
            if !orderStore.order(order, validates: .shipped) && !orderStore.order(order, validates: .driveThru) {
                
                var text = "Ship and send Drive thru"
                if orderStore.isUpdatingStatus(of: order, to: .shipped) {
                    text += " (shipping...)"
                }
                if orderStore.isSendingDriveThru(for: order) {
                    text += " (sending...)"
                }
                items.append(OrderStatusTag(text: text, status: .actionRequired, action: {
                    Task {
                        await orderStore.updateStatus(of: order, to: .shipped)
                        await orderStore.sendDriveThru(for: order)
                    }
                }))
            } else {
                if !orderStore.order(order, validates: .shipped) {
                    items.append(OrderStatusTag(text: "Mark Shipped", status: .actionRequired))
                }
                if !orderStore.order(order, validates: .driveThru) {
                    items.append(OrderStatusTag(text: "Send Drive thru", status: .actionRequired))
                }
            }
            
        case .inTransit, .inTransitFor30PlusDays:
            
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(OrderStatusTag(text: "Shipped \(formattedDate)", status: .waitingOnExternalAction))
            
            if order.unchangedFor30Days {
                items.append(OrderStatusTag(text: "Mark Completed and give feedback", status: .actionRequired, action: {
                    Task {
                        await orderStore.updateStatus(of: order, to: .completed)
                        await feedbackStore.postPraiseFeedback(for: order)
                    }
                }))
            }
            
        case .received:
                
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(OrderStatusTag(text: "Received \(formattedDate)", status: .completed))
            
            items.append(OrderStatusTag(text: "Waiting Completed or buyer feedback", status: .waitingOnExternalAction))
        
        case .closedByBuyer:
                
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            if order.status == .completed {
                items.append(OrderStatusTag(text: "Completed \(formattedDate)", status: .completed))
            } else {
                items.append(OrderStatusTag(text: "Received \(formattedDate)", status: .completed))
            }
            
            items.append(OrderStatusTag(text: "Give feedback", status: .actionRequired, action: {
                Task {
                    await feedbackStore.postPraiseFeedback(for: order)
                }
            }))
            
        case .recentlyClosed, .closed:
            
            let formattedDate = formatter.localizedString(for: order.dateStatusChanged, relativeTo: Date.now)
            items.append(OrderStatusTag(text: "Closed \(formattedDate)", status: .completed))
        }
        
        return items
    }
}



#Preview {
    
    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    OrdersMainListItem(order: order)
        .inject(env)
}
