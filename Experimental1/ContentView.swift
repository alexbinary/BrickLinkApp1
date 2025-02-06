
import SwiftUI



struct ContentView1: View {
    
    
    @EnvironmentObject var controller: Controller
    

    var body: some View {
        
        let _ = print("ContentView1.body")
        
        VStack {
            
            Text(controller.data1)
            Button("Mutate1") {
                controller.mutate1()
            }
        }
        .padding()
    }
}



struct ContentView2: View {
    
    
    @EnvironmentObject var controller: Controller
    

    var body: some View {
        
        let _ = print("ContentView2.body")

        VStack {

            Text(controller.data2)
            Button("Mutate2") {
                controller.mutate2()
            }
        }
        .padding()
    }
}
