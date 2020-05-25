//
//  ContentView.swift
//  blahblah
//
//  Created by 陈敏华 on 2020/5/23.
//  Copyright © 2020 陈敏华. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    
    @Environment(\.managedObjectContext) var moc
    
    
    var body: some View {
        NavigationView {
            VStack {
                RecordingsList()
                
                Button(action: audioRecorder.recording == false ? {self.audioRecorder.startRecording()} :
                {
                    print(type(of: self.moc))
                    self.audioRecorder.stopRecording(moc: self.moc)}) {
                    Image(systemName: audioRecorder.recording == false ?
                        "circle.fill" : "stop.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .foregroundColor(.red)
                        .padding(.bottom, 40)
                }.animation(.default)
            }
        .navigationBarTitle("voice recorder")
            .navigationBarTitle("Voice recorder")
            .navigationBarItems(trailing: EditButton())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioRecorder: AudioRecorder())
    }
}
