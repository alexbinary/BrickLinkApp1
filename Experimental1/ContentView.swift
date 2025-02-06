
import SwiftUI



struct ContentView1: View {
    
    
    @Environment(Controller.self) var controller
    

    var body: some View {
        
        let _ = print("ContentView1.body")
        
        VStack {
            
            Text(controller.read(0))
            Button("Mutate1") {
                controller.mutate(0)
            }
        }
        .padding()
    }
}



struct ContentView2: View {
    
    
    @Environment(Controller.self) var controller
    

    var body: some View {
        
        let _ = print("ContentView2.body")

        VStack {

            Text(controller.read(1))
            Button("Mutate2") {
                controller.mutate(1)
            }
        }
        .padding()
    }
}
