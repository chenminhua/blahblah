//
//  ContentView.swift
//  blahblah
//
//  Created by 陈敏华 on 2020/5/23.
//  Copyright © 2020 陈敏华. All rights reserved.
//

import SwiftUI
import AVFoundation
import CoreData

struct AudioRecorderView: View {
    @Environment(\.managedObjectContext) var moc
    // to notify observing views about changes
    
    @State private var audioRecorder: AVAudioRecorder!
    
    @State private var recordedAt: Date?
    @State private var fileurl: URL?
        
    @State private var recording = false {
        didSet {
            if recording == false {
                recordedAt = nil
                fileurl = nil
            }
        }
    }
    
    var body: some View {
        Button(action: recording == false ? {self.startRecording()} :
        {
            self.stopRecording(moc: self.moc)}) {
            Image(systemName: recording == false ?
                "circle.fill" : "stop.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .foregroundColor(.red)
                .padding(.bottom, 40)
        }.animation(.default)
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
       
       func stopRecording(moc: NSManagedObjectContext) {
           audioRecorder.stop()
           // id, recordedAt, fileURL, duration, averagePowerList
           let newRecording = Recording(context: moc)
           newRecording.id = UUID()
           newRecording.recordedAt = recordedAt
           newRecording.fileURL = fileurl
           newRecording.duration = Int32(Date().distance(to: recordedAt!))
           try! moc.save()
           recording = false
       }

       

       
       func genAvAudioFileURL() -> URL {
           return AudioFilePath.appendingPathComponent("\(self.recordedAt!.toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
       }
}

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    
    var body: some View {
        NavigationView {
            VStack {
                RecordingsList()
                
                AudioRecorderView()
            }
        .navigationBarTitle("voice recorder")
            .navigationBarTitle("Voice recorder")
            .navigationBarItems(trailing: EditButton())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
