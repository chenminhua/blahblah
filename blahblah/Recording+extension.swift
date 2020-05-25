//
//  Recording+extension.swift
//  blahblah
//
//  Created by 陈敏华 on 2020/5/25.
//  Copyright © 2020 陈敏华. All rights reserved.
//

import Foundation

extension Recording {
    func genAvAudioFileURL() -> URL {
        return AudioFilePath.appendingPathComponent("\(self.recordedAt!.toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
    }
}
