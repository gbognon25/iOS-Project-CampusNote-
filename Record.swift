
import UIKit
import Speech

class Record: UIViewController, SFSpeechRecognizerDelegate {
    
    // MARK : - Variable
    @IBOutlet weak var STT: UIButton!
    @IBOutlet weak var RecordTextView: UITextView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var MemoData = [String]()
    //Variable_End
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let MemoNumber = UserDefaults.standard.object(forKey: "MemoNumber") as! Int
        
        
        if MemoNumber == -1 {
            if UserDefaults.standard.object(forKey: "MemoData") as? [String] != nil {
                MemoData = UserDefaults.standard.object(forKey: "MemoData") as! [String]
                RecordTextView.text = ""
            }
        } else {
            MemoData = UserDefaults.standard.object(forKey: "MemoData") as! [String]
            RecordTextView.text = MemoData[MemoNumber]
        }
        
        
        speechRecognizer?.delegate = self
    }
    
    // MARK: - Action
    @IBAction func Save(_ sender: Any) {
        let MemoNumber = UserDefaults.standard.object(forKey: "MemoNumber") as! Int
        if MemoNumber == -1 {
            MemoData.insert(RecordTextView.text, at: 0)
            UserDefaults.standard.set(MemoData, forKey: "MemoData")
        } else {
            MemoData.remove(at: MemoNumber)
            MemoData.insert(RecordTextView.text, at: MemoNumber)
            UserDefaults.standard.set(MemoData, forKey: "MemoData")
        }
    }
    @IBAction func Delete(_ sender: Any) {
        let MemoNumber = UserDefaults.standard.object(forKey: "MemoNumber") as! Int
        
        if MemoNumber != -1 {
            MemoData.remove(at: MemoNumber)
            UserDefaults.standard.set(MemoData, forKey: "MemoData")
        }
    }
    
    @IBAction func speechToText(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            STT.isEnabled = false
            STT.setTitle("Start", for: .normal)
        } else {
            startRecording()
            STT.setTitle("Stop", for: .normal)
        }
    }
    //Action_End
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.RecordTextView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.STT.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            STT.isEnabled = true
        } else {
            STT.isEnabled = false
        }
    }
}
