//
//  RecordingsList.swift
//  blahblah
//
//  Created by 陈敏华 on 2020/5/23.
//  Copyright © 2020 陈敏华. All rights reserved.
//

import SwiftUI

struct RecordingsList: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: Recording.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Recording.recordedAt, ascending: false)
    ])
    var recordings: FetchedResults<Recording>
    
    var body: some View {
        return List {
            ForEach(recordings, id: \.id) { recording in
                RecordingRow(audioURL: recording.genAvAudioFileURL())
            }
                .onDelete(perform: delete)
        }
    }
    
    func delete(at offsets: IndexSet) {
        var uuids = [UUID]()
        for index in offsets {
            uuids.append(recordings[index].id!)
        }
        deleteRecording(uuids: uuids)
    }
    
    func deleteRecording(uuids: [UUID]) {

        for uuid in uuids {
            // 删除文件
            let recording = recordings.filter { $0.id == uuid }[0]
            do {
                try FileManager.default.removeItem(at: recording.genAvAudioFileURL())
            } catch {
                print("File could not be deleted!")
            }
            moc.delete(recording)
            try? moc.save()
            
        }
    }
    
    
}

struct RecordingRow: View {
    
    var audioURL: URL
    
    @ObservedObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        HStack {
//            Text("\(audioURL.lastPathComponent)")
//            Spacer()
            Text("\(audioURL.lastPathComponent)")
            Spacer()
            if audioPlayer.isPlaying == false {
                Button(action: {
                    self.audioPlayer.startPlayback(audio: self.audioURL)
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

struct RecordingsList_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsList()
    }
}
