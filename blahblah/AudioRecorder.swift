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


let AvAudioRecorderSettings = [
    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),   // 格式
    AVSampleRateKey: 12000,                     // 采样率
    AVNumberOfChannelsKey: 1,                   // 声道数
    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue     // 编码清晰度
]

// specify the location where recording should be saved
let AudioFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

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
        // create a recording session
        let recordingSession = AVAudioSession.sharedInstance()
        
        // define the type for our recording session
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        // the file should be named after the date and time of the recording and have the .m4a format
        let audioFilename = AudioFilePath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
        
        // start the recording and inform views
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: AvAudioRecorderSettings)
            audioRecorder.record()

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
