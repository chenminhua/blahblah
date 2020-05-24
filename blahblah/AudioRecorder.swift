//
//  AudioRecorder.swift
//  blahblah
//
//  Created by 陈敏华 on 2020/5/23.
//  Copyright © 2020 陈敏华. All rights reserved.
//

import Foundation
import Combine
import AVFoundation

// AvAudioSession
let AudioSession = AVAudioSession.sharedInstance()

let AvAudioRecorderSettings = [
    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),   // 格式
    AVSampleRateKey: 12000,                     // 采样率
    AVNumberOfChannelsKey: 1,                   // 声道数
    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue     // 编码清晰度
]

// specify the location where recording should be saved
let AudioFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]


func genAvAudioFileURL() -> URL {
    return AudioFilePath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
}


class AudioRecorder: ObservableObject {
    // to notify observing views about changes
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    
    var audioRecorder: AVAudioRecorder!
    
    var recordings = [Recording]()
    
    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    init() {
        fetchRecordings()
    }
    
    // start a record session
    func startRecording() {
        
        print("start recording")
        // define the type for our recording session
        do {
            try AudioSession.setCategory(.playAndRecord, mode: .default)
            try AudioSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        // start the recording and inform views
        do {
            audioRecorder = try AVAudioRecorder(url: genAvAudioFileURL(), settings: AvAudioRecorderSettings)
            audioRecorder.record()
            
            audioRecorder.isMeteringEnabled = true
            
            DispatchQueue.global(qos: .userInitiated).async {
                while self.recording {
                    self.audioRecorder.updateMeters()
                    var peekPower = self.audioRecorder.averagePower(forChannel: 0)
                    print("peekpower \(peekPower)")
                    sleep(1)
                    self.audioRecorder.updateMeters()
                    peekPower = self.audioRecorder.averagePower(forChannel: 0)
                    print("peekpower \(peekPower)")
                }
            }
            
            recording = true
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        recording = false
        fetchRecordings()
    }
    
    func fetchRecordings() {
        recordings.removeAll()
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try!fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        
        for audio in directoryContents {
            let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
            recordings.append(recording)
        }
        
        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
        objectWillChange.send(self)
    }
    
    func deleteRecording(urlsToDelete: [URL]) {
        
        for url in urlsToDelete {
            print(url)
            do {
               try FileManager.default.removeItem(at: url)
            } catch {
                print("File could not be deleted!")
            }
        }
        
        fetchRecordings()
        
    }
}


extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}
