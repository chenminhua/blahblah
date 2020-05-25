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
import SwiftUI

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





class AudioRecorder: ObservableObject {
    // to notify observing views about changes
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    
    var audioRecorder: AVAudioRecorder!
    
    @FetchRequest(entity: Recording.entity(), sortDescriptors: [])
    var recordings: FetchedResults<Recording>
    
    var recordedAt: Date?
    var fileurl: URL?
    
    @Environment(\.managedObjectContext) var moc
    
    var recording = false {
        didSet {
            objectWillChange.send(self)
            if recording == false {
                recordedAt = nil
                fileurl = nil
            }
        }
    }
    
    
    init() {}
    
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
            self.recordedAt = Date()
            self.fileurl = genAvAudioFileURL()
            audioRecorder = try AVAudioRecorder(url: self.fileurl!, settings: AvAudioRecorderSettings)
            audioRecorder.record()
            
            audioRecorder.isMeteringEnabled = true
            
            DispatchQueue.global(qos: .userInitiated).async {
                var averagePowerList = [Float]()
                while self.recording {
                    self.audioRecorder.updateMeters()
                    averagePowerList.append(self.audioRecorder.averagePower(forChannel: 0))
                    sleep(1)
                }
                // make a file for store averagePowerList
            }
            
            recording = true
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        let newRecording = Recording()
        try? self.moc.save()
        recording = false
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
        
//        fetchRecordings()
        
    }
    
    func genAvAudioFileURL() -> URL {
        return AudioFilePath.appendingPathComponent("\(self.recordedAt!.toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
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
