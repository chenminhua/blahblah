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
