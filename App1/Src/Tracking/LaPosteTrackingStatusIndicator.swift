
import SwiftUI
import Core


struct LaPosteTrackingStatusIndicator: View {
    
    
    @Environment(TrackingStore.self)
    var trackingMiddleController
    
    
    let order: Order
    var status: LaPosteTrackingStatus? { trackingMiddleController.laPosteTrackingStatus(for: order) }
    
    
    var body: some View {
        
        Text("La Poste: \(status?.rawValue ?? "")")
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .roundedContainer(style: .tag(baseColor: color))
            .onChange(of: order, initial: true) { Task {
                await trackingMiddleController.reloadLaPosteTrackingStatus(for: order)
            }}
    }
    
    
    var color: Color {
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
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
        }.padding()
    }
    .inject(env)
}
