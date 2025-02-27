
import SwiftUI



struct ObservationRootView: View {

    @State var controller = Controller()
    

    var body: some View {

        ContentView1()
            .environment(controller)
        ContentView2()
            .environment(controller)
    }
}



#Preview {
    ObservationRootView()
}
