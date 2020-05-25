//
//  RecordingRow.swift
//  blahblah
//
//  Created by 陈敏华 on 2020/5/25.
//  Copyright © 2020 陈敏华. All rights reserved.
//

import SwiftUI


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
