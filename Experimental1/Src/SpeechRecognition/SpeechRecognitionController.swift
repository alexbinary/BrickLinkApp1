
import SwiftUI
import Speech



@Observable
class SpeechRecognitionController: NSObject, SFSpeechRecognizerDelegate {
    
    var microphoneAuthorized: Bool?
    
    var speechRecognitionAvailable: Bool?
    var speechRecognitionAuthorized: Bool?
    
    var listening = false
    var recognizedText: String?
    
    
    var audioEngine: AVAudioEngine!
    var inputNode: AVAudioInputNode!
    
    var speechRecognizer: SFSpeechRecognizer!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    var recognitionTask: SFSpeechRecognitionTask!
    
    
    override init() {
        super.init()
        
        updateMicrophoneAuthorisationStatus()
        updateSpeechRecognitionAuthorisationStatus()
        print("Microphone authorization: \(microphoneAuthorisationStatus)")
        print("Speech recognition authorization \(speechRecognitionAuthorisationStatus)")
        
        print("Ready speech recognition")
        let locale = Locale(identifier: "fr_FR")
        print("Locale: \(locale)")
        speechRecognizer = SFSpeechRecognizer(locale: locale)
        guard let speechRecognizer = speechRecognizer else { fatalError("Unable to created a SFSpeechRecognizer object") }
        speechRecognizer.delegate = self
    }
    
    
    func start() async {
        
        let microphoneStatus = await requestMicrophoneAuthorisation()
        guard microphoneStatus == .authorized else {
            print("Microphone not authorized (\(microphoneStatus))")
            return
        }
        print("Microphone authorized (\(microphoneStatus))")
        
        let speechRecognitonStatus = await requestSpeechRecognitionAuthorisation()
        guard speechRecognitonStatus == .authorized else {
            print("Speech recognition not authorized (\(speechRecognitonStatus))")
            return
        }
        print("Speech recognition authorized (\(speechRecognitonStatus))")
        
        do {
            try initAudio()
        } catch {
            print("Failed to init audio: \(error)")
            return
        }
        print("Audio init success")
        
        startRecognition()
        print("Recognition active")
        
        listening = true
    }
    
    
    func stop() {
        
        stopRecognition()
        stopAudio()
        
        listening = false
    }
    
    
    var speechRecognitionAuthorisationStatus: SFSpeechRecognizerAuthorizationStatus {
        
        SFSpeechRecognizer.authorizationStatus()
    }
    
    
    func updateSpeechRecognitionAuthorisationStatus() {
        
        speechRecognitionAuthorized = {
            switch speechRecognitionAuthorisationStatus {
            case .notDetermined: nil
            case .authorized: true
            default: false
            }
        }()
    }
    
    
    func requestSpeechRecognitionAuthorisation() async -> SFSpeechRecognizerAuthorizationStatus {
        
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { _ in
                self.updateSpeechRecognitionAuthorisationStatus()
                continuation.resume(returning: self.speechRecognitionAuthorisationStatus)
            }
        }
    }

    
    var microphoneAuthorisationStatus: AVAuthorizationStatus {
        
        AVCaptureDevice.authorizationStatus(for: .audio)
    }
    
    
    func updateMicrophoneAuthorisationStatus() {
        
        microphoneAuthorized = {
            switch microphoneAuthorisationStatus {
            case .notDetermined: nil
            case .authorized: true
            default: false
            }
        }()
    }
    
    
    func requestMicrophoneAuthorisation() async -> AVAuthorizationStatus {
        
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { _ in
                self.updateMicrophoneAuthorisationStatus()
                continuation.resume(returning: self.microphoneAuthorisationStatus)
            }
        }
    }
    
    
    func initAudio() throws {
        
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    
    func stopAudio() {
        
        audioEngine.stop()
        inputNode.removeTap(onBus: 0)
    }
    
    
    func startRecognition() {
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, time) in
            self.recognitionRequest?.append(buffer)
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            
            if let error = error {
                
                self.stopAudio()
                print("Recognition error: \(error)")
                
            } else if let result = result {
                
                let transcribedText = result.bestTranscription.formattedString
                print("Transcribed: \(transcribedText)")
                
                if let lastWord = transcribedText.split(separator: " ").last {
                    print("lastWord: \(lastWord)")
                    
                    if let result = lastWord.wholeMatch(of: /[0-9]+/) {
                        
                        let number = String(lastWord)
                        print("number: \(number)")
                        self.recognizedText = number
                        
                    } else {
                     
                        // https://stackoverflow.com/questions/34032509/how-to-convert-an-english-string-of-a-number-into-a-float-e-g-twenty-six-26
                        let dict = [
                            "un": 1,
                            "deux": 2,
                            "trois": 3,
                            // TODO
                        ]

                        var number = 0

                        dict.forEach({ (key: String, value: Int) in
                            if lastWord.lowercased().contains(key) {
                                number += value
                            }
                        })
                        
                        print("number: \(number)")
                        self.recognizedText = String(number)
                    }
                }
                if result.isFinal {
                    self.stopAudio()
                    print("Recognition complete")
                }
            }
        }
    }
    
    
    func stopRecognition() {
        
        recognitionRequest.endAudio()
    }
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
        if available {
            print("Speech recognition is available")
        } else {
            print("Speech recognition is not available")
        }
        
        self.speechRecognitionAvailable = available
    }
}



extension AVAuthorizationStatus: @retroactive CustomStringConvertible {
    
    public var description: String {
        
        switch self {
            
        case .notDetermined:
            "notDetermined"
            
        case .restricted:
            "restricted"
            
        case .denied:
            "denied"
            
        case .authorized:
            "authorized"
            
        @unknown default:
            "unknown"
        }
    }
}



extension SFSpeechRecognizerAuthorizationStatus: @retroactive CustomStringConvertible {
    
    public var description: String {
        
        switch self {
            
        case .notDetermined:
            "notDetermined"
        
        case .denied:
            "denied"
        
        case .restricted:
            "restricted"
        
        case .authorized:
            "authorized"
        
        @unknown default:
            "unknown"
        }
    }
}
