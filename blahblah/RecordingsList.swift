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
                RecordingRow(recording: recording)
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


struct RecordingsList_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for _ in 1...4 {
            var newr = Recording.init(context: context)
            newr.recordedAt = Date()
        }
        
       
        return RecordingsList().environment(\.managedObjectContext, context)
        
    }
}
