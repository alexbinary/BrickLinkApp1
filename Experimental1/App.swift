
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
    
    var data1: String { store.dataCollection["d1"]!.data }
    var data2: String { store.dataCollection["d2"]!.data }
    
    func read1() -> String {
        data1
    }
    
    func read2() -> String {
        data2
    }
    
    func mutate1() {
        store.mutate1()
    }
    
    func mutate2() {
        store.mutate2()
    }
}



@Observable
class Store {
    
    var dataCollection = ["d1": Data(), "d2": Data()]
    
    func mutate1() {
        dataCollection["d1"] = Data()
        dataCollection["d1"]!.data = "\(Date())"
    }
    
    func mutate2() {
        dataCollection["d2"]!.data = "\(Date())"
    }
}



@Observable
class Data {
    
    var data: String = "d"
}
