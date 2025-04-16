
import SwiftUI



struct LaPosteTrackingStatusIndicator: View {
    
    
    @Environment(TrackingStore.self)
    var trackingStore
    
    
    let order: Order
    var status: LaPosteTrackingStatus? { trackingStore.laPosteTrackingStatus(for: order) }
    var updating: Bool { trackingStore.isLoadingLaPosteTrackingStatus(for: order) }
    
    
    var body: some View {
        
        HStack {
            if updating {
                ProgressView()
                    .controlSize(.mini)
            }
            Text("La Poste: \(statusDescription)")
        }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .roundedContainer(style: .tag(baseColor: statusColor))
    }
    
    
    var statusDescription: String {
        switch status {
        case .none: "no data"
        case .noData: "Pending"
        case .inTransit: "In transit"
        case .delivered: "Delivered"
        }
    }
    
    
    var statusColor: Color {
        switch status {
        case .none: .gray
        case .noData: .red
        case .inTransit: .yellow
        case .delivered: .green
        }
    }
}


#Preview {
    
    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    VStack {
        Group {
            LaPosteTrackingStatusIndicator(order: order)
        }.padding()
    }
    .inject(env)
}
