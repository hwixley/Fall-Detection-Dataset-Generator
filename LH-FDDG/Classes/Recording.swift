//
//  Recording.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 06/07/2021.
//

import Foundation

struct RecordingInfo {
    var id: String
    var action: String
    var includesFall: Bool
    var fallType: String
    var subjectId: String
    var phonePlacement: String
    var numberOfRecordings: Int
}

struct RecordingDocument {
    var data: String
    var snippetIndex: Int
}
