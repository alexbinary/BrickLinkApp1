
import SwiftUI



struct SpeechRecognitionRootView: View {

    
    @State var controller = SpeechRecognitionController()
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
            
            Grid(alignment: .leading, verticalSpacing: 12) {
                
                GridRow {
                    Text("Microphone authorisation")
                    if let authorized = controller.microphoneAuthorized {
                        Text(authorized ? "Granted" : "Denied")
                    } else {
                        Text("undetermined")
                    }
                }
                
                GridRow {
                    Text("Speech recognition availability")
                    if let available = controller.speechRecognitionAvailable {
                        Text(available ? "Available" : "Unavailable")
                    } else {
                        Text("undetermined")
                    }
                }
                
                GridRow {
                    Text("Speech recognition authorisation")
                    if let authorized = controller.speechRecognitionAuthorized {
                        Text(authorized ? "Granted" : "Denied")
                    } else {
                        Text("undetermined")
                    }
                }
            }
            
            HStack {
                
                Group {
                    if controller.listening {
                        Button("Stop") {
                            controller.stop()
                        }
                    } else {
                        Button("Start") {
                            Task { await controller.start() }
                        }
                    }
                }
                .disabled(!controller.ready)
                
                if controller.listening {
                    Text("Listening")
                }
            }
            
            Group {
                if let text = controller.recognizedText {
                    Text(text)
                } else {
                    Text("Recognized text will appear here").foregroundStyle(.secondary).italic()
                }
                if let number = controller.recognizedNumber {
                    Text("Recognized number: \(number)")
                }
            }
            .font(.title)
            .lineLimit(5, reservesSpace: true)
        }
        .padding()
    }
}



#Preview {
    SpeechRecognitionRootView()
}
