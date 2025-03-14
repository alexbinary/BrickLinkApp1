
import SwiftUI
import Speech



@Observable
class SpeechRecognitionController: NSObject, SFSpeechRecognizerDelegate {
    
    public var microphoneAuthorized: Bool?
    public var speechRecognitionAvailable: Bool?
    public var speechRecognitionAuthorized: Bool?
    public var ready: Bool { ![microphoneAuthorized, speechRecognitionAvailable, speechRecognitionAuthorized].contains(false) }
    
    public var listening = false
    public var recognizedText: String?
    
    private var audioEngine: AVAudioEngine!
    private var inputNode: AVAudioInputNode!
    
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    
    
    public override init() {
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
    
    
    public func start() async {
        
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
    
    
    public func stop() {
        
        stopRecognition()
        stopAudio()
        
        listening = false
    }
    
    
    private var speechRecognitionAuthorisationStatus: SFSpeechRecognizerAuthorizationStatus {
        
        SFSpeechRecognizer.authorizationStatus()
    }
    
    
    private func updateSpeechRecognitionAuthorisationStatus() {
        
        speechRecognitionAuthorized = {
            switch speechRecognitionAuthorisationStatus {
            case .notDetermined: nil
            case .authorized: true
            default: false
            }
        }()
    }
    
    
    private func requestSpeechRecognitionAuthorisation() async -> SFSpeechRecognizerAuthorizationStatus {
        
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { _ in
                self.updateSpeechRecognitionAuthorisationStatus()
                continuation.resume(returning: self.speechRecognitionAuthorisationStatus)
            }
        }
    }

    
    private var microphoneAuthorisationStatus: AVAuthorizationStatus {
        
        AVCaptureDevice.authorizationStatus(for: .audio)
    }
    
    
    private func updateMicrophoneAuthorisationStatus() {
        
        microphoneAuthorized = {
            switch microphoneAuthorisationStatus {
            case .notDetermined: nil
            case .authorized: true
            default: false
            }
        }()
    }
    
    
    private func requestMicrophoneAuthorisation() async -> AVAuthorizationStatus {
        
        await AVCaptureDevice.requestAccess(for: .audio)
        updateMicrophoneAuthorisationStatus()
        return microphoneAuthorisationStatus
    }
    
    
    private func initAudio() throws {
        
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    
    private func stopAudio() {
        
        audioEngine.stop()
        inputNode.removeTap(onBus: 0)
    }
    
    
    private func startRecognition() {
        
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
                
                self.processRecognitionResult(result)
                
                if result.isFinal {
                    self.stopAudio()
                    print("Recognition complete")
                }
            }
        }
    }
    
    
    private func processRecognitionResult(_ result: SFSpeechRecognitionResult) {
        
        let transcribedText = result.bestTranscription.formattedString
        print("Transcribed: \(transcribedText)")
        
        if let lastWord = transcribedText.split(separator: " ").last {
            print("lastWord: \(lastWord)")
            
            if let _ = lastWord.wholeMatch(of: /[0-9]+/) {
                
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
    }
    
    
    private func stopRecognition() {
        
        recognitionRequest.endAudio()
    }
    
    
    internal func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
        if available {
            print("Speech recognition is available")
        } else {
            print("Speech recognition is not available")
        }
        
        self.speechRecognitionAvailable = available
    }
}
