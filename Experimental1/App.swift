
import SwiftUI



@main
struct Experimental1: App {
    
    
    @State var controller = Controller()
    

    var body: some Scene {

        WindowGroup {
            ContentView1()
                .environment(controller)
            ContentView2()
                .environment(controller)
        }
    }
}



@Observable
class Controller {
    
    var store = Store()
    
    var data: [String] { store.data }
    
    func read(_ idx: Int) -> String {
        data[idx]
    }
    
    func mutate(_ idx: Int) {
        store.mutate(idx)
    }
}



@Observable
class Store {
    
    var data = [String](repeating: "d", count: 5)
    
    func mutate(_ idx: Int) {
        data[idx] = "\(Date())"
    }
}
