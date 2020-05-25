//
//  RecordingRow.swift
//  blahblah
//
//  Created by 陈敏华 on 2020/5/25.
//  Copyright © 2020 陈敏华. All rights reserved.
//

import SwiftUI


struct RecordingRow: View {
    
    var recording: Recording
    
    @ObservedObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        HStack {
//            Text("\(audioURL.lastPathComponent)")
//            Spacer()
            //Text("\(audioURL.lastPathComponent)")
            Text("\(recording.recordedAt!.toString(dateFormat: "yyyy-MM-dd hh:mm:ss"))")
            Spacer()
            if audioPlayer.isPlaying == false {
                Button(action: {
                    self.audioPlayer.startPlayback(audio: self.recording.genAvAudioFileURL())
                }) {
                    Image(systemName: "play.circle")
                        .imageScale(.large)
                }
            } else {
                Button(action: {
                    self.audioPlayer.stopPlayback()
                }) {
                    Image(systemName: "stop.fill")
                        .imageScale(.large)
                }
            }
        }
    }
}


struct RecordingRow_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //Test data
        let newRecording = Recording.init(context: context)
        newRecording.recordedAt = Date()
        newRecording.id = UUID()
        
        return RecordingRow(recording: newRecording).environment(\.managedObjectContext, context)
    }
}

