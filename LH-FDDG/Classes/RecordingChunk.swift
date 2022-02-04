//
//  RecordingChunk.swift
//  LH-FDDG
//
//  Created by Harry Wixley on 28/01/2022.
//

import Foundation

struct RecordingMeta: Encodable, Decodable {
    var _id = NSUUID().uuidString
    var subject_id: String
    var phone_placement: String
    var recording_duration: Double
    var chunk_ids: [String]
    
    func parseHeaders() -> [String: AnyObject] {
        return ["_id": _id as AnyObject, "subject_id": subject_id as AnyObject, "phone_placement": phone_placement as AnyObject, "recording_duration": recording_duration as AnyObject, "chunk_ids": chunk_ids as AnyObject]
    }
}

struct RecordingChunk: Encodable, Decodable {
    var _id : String = NSUUID().uuidString
    var recording_id : String
    var chunk_index : Int
    var labels: [Bool] = []
    var p_ecg: [Double] = []
    var p_hr: [Double] = []
    var p_contact: [Bool] = []
    var p_acc_x: [Double] = []
    var p_acc_y: [Double] = []
    var p_acc_z: [Double] = []
    var acc_x: [Double] = []
    var acc_y: [Double] = []
    var acc_z: [Double] = []
    var gyr_x: [Double] = []
    var gyr_y: [Double] = []
    var gyr_z: [Double] = []
    var gra_x: [Double] = []
    var gra_y: [Double] = []
    var gra_z: [Double] = []
    var mag_x: [Double] = []
    var mag_y: [Double] = []
    var mag_z: [Double] = []
    var att_roll: [Double] = []
    var att_pitch: [Double] = []
    var att_yaw: [Double] = []
    var delta_heading: [Double] = []
    
    func parseHeaders() -> [String: AnyObject] {
        return ["_id": _id as AnyObject, "recording_id": recording_id as AnyObject, "chunk_index": chunk_index as AnyObject, "labels": Array(labels.prefix(50)) as AnyObject, "p_ecg": p_ecg as AnyObject, "p_hr": p_hr as AnyObject, "p_contact": p_contact as AnyObject, "p_acc_x": p_acc_x as AnyObject, "p_acc_y": p_acc_y as AnyObject, "p_acc_z": p_acc_z as AnyObject, "acc_x": Array(acc_x.prefix(50)) as AnyObject, "acc_y": Array(acc_y.prefix(50)) as AnyObject, "acc_z": Array(acc_z.prefix(50)) as AnyObject, "gyr_x": Array(gyr_x.prefix(50)) as AnyObject, "gyr_y": Array(gyr_y.prefix(50)) as AnyObject, "gyr_z": Array(gyr_z.prefix(50)) as AnyObject, "gra_x": Array(gra_x.prefix(50)) as AnyObject, "gra_y": Array(gra_y.prefix(50)) as AnyObject, "gra_z": Array(gra_z.prefix(50)) as AnyObject, "mag_x": Array(mag_x.prefix(50)) as AnyObject, "mag_y": Array(mag_y.prefix(50)) as AnyObject, "mag_z": Array(mag_z.prefix(50)) as AnyObject, "att_roll": Array(att_roll.prefix(50)) as AnyObject, "att_pitch": Array(att_pitch.prefix(50)) as AnyObject, "att_yaw": Array(att_yaw.prefix(50)) as AnyObject, "delta_heading": Array(delta_heading.prefix(50)) as AnyObject]
    }
    
    mutating func resetChunk() {
        self._id = NSUUID().uuidString
        self.chunk_index += 1
        self.labels = Array(self.labels.suffix(from: self.labels.count > 50 ? 50 : self.labels.endIndex))
        self.p_ecg = []
        self.p_hr = []
        self.p_contact = []
        self.p_acc_x = []
        self.p_acc_y = []
        self.p_acc_z = []
        self.acc_x = Array(self.acc_x.suffix(from: self.acc_x.count > 50 ? 50 : self.acc_x.endIndex))
        self.acc_y = Array(self.acc_y.suffix(from: self.acc_y.count > 50 ? 50 : self.acc_y.endIndex))
        self.acc_z = Array(self.acc_z.suffix(from: self.acc_z.count > 50 ? 50 : self.acc_z.endIndex))
        self.gyr_x = Array(self.gyr_x.suffix(from: self.gyr_x.count > 50 ? 50 : self.gyr_x.endIndex))
        self.gyr_y = Array(self.gyr_y.suffix(from: self.gyr_y.count > 50 ? 50 : self.gyr_y.endIndex))
        self.gyr_z = Array(self.gyr_z.suffix(from: self.gyr_z.count > 50 ? 50 : self.gyr_z.endIndex))
        self.gra_x = Array(self.gra_x.suffix(from: self.gra_x.count > 50 ? 50 : self.gra_x.endIndex))
        self.gra_y = Array(self.gra_y.suffix(from: self.gra_y.count > 50 ? 50 : self.gra_y.endIndex))
        self.gra_z = Array(self.gra_z.suffix(from: self.gra_z.count > 50 ? 50 : self.gra_z.endIndex))
        self.mag_x = Array(self.mag_x.suffix(from: self.mag_x.count > 50 ? 50 : self.mag_x.endIndex))
        self.mag_y = Array(self.mag_y.suffix(from: self.mag_y.count > 50 ? 50 : self.mag_y.endIndex))
        self.mag_z = Array(self.mag_z.suffix(from: self.mag_z.count > 50 ? 50 : self.mag_z.endIndex))
        self.att_roll = Array(self.att_roll.suffix(from: self.att_roll.count > 50 ? 50 : self.att_roll.endIndex))
        self.att_pitch = Array(self.att_pitch.suffix(from: self.att_pitch.count > 50 ? 50 : self.att_pitch.endIndex))
        self.att_yaw = Array(self.att_yaw.suffix(from: self.att_yaw.count > 50 ? 50 : self.att_yaw.endIndex))
        self.delta_heading = Array(self.delta_heading.suffix(from: self.delta_heading.count > 50 ? 50 : self.delta_heading.endIndex))
    }
}

struct PostQueue {
    var queue: [RecordingChunk]
    var meta: RecordingMeta
    
    func getIDs() -> [String] {
        var output : [String] = []
        for chunk in queue {
            output.append(chunk._id)
        }
        return output
    }
}
