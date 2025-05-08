
import SwiftUI



struct OrderStatusView: View {
    
    
    @Environment(\.navigationController)
    var nav: NavigationControllerProtocol!
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    
    var order: Order? {
        
        switch nav.sidebar {
            
        case .orders:
            
            if let orderId = nav.orderStack.last {
                return orderStore.order(withId: orderId)
            }
            
        default:
            break
        }
        
        return nil
    }
    
    
    var body: some View {
            
        if let order = order {
            
            let statusBinding = Binding<OrderStatus> {
                order.status
            } set: { newStatus in
                Task { await orderStore.updateStatus(of: order, to: newStatus) }
            }
            
            let statuses = [OrderStatus.paid, .packed, .shipped, .completed]
            
            Picker("Status", selection: statusBinding) {
                
                ForEach(statuses, id: \.self) { status in
                    
                    Text(status.rawValue)
                        .fontWeight(statusBinding.wrappedValue == status ? .bold : .regular)
                        .tag(status)
                }
            }
        }
    }
}



#Preview {
    WindowRootView()
        .frame(width: 1200, height: 800)
        .previewEnv()
}
