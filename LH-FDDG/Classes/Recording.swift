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

struct Recording: Encodable, Decodable {
    var subject_id: String
    var fall_time: Double
    var fall_type: String
    var recording_duration: Double
    var ground_time: Double
    var action: String
    var phone_placement: String
    var p_ecg: [Double]
    var p_hr: [Double]
    var p_contact: [Bool]
    var p_acc_x: [Double]
    var p_acc_y: [Double]
    var p_acc_z: [Double]
    var acc_x: [Double]
    var acc_y: [Double]
    var acc_z: [Double]
    var gyr_x: [Double]
    var gyr_y: [Double]
    var gyr_z: [Double]
    var gra_x: [Double]
    var gra_y: [Double]
    var gra_z: [Double]
    var mag_x: [Double]
    var mag_y: [Double]
    var mag_z: [Double]
    var att_roll: [Double]
    var att_pitch: [Double]
    var att_yaw: [Double]
    var delta_heading: [Double]
    var timestamps: [Double]
    
    func parseHeaders() -> [String: AnyObject] {
        return ["subject_id": subject_id as AnyObject, "fall_time": fall_time as AnyObject, "fall_type": fall_type as AnyObject, "recording_duration": recording_duration as AnyObject, "ground_time": ground_time as AnyObject, "action": action as AnyObject, "phone_placement": phone_placement as AnyObject, "p_ecg": p_ecg as AnyObject, "p_hr": p_hr as AnyObject, "p_contact": p_contact as AnyObject, "p_acc_x": p_acc_x as AnyObject, "p_acc_y": p_acc_y as AnyObject, "p_acc_z": p_acc_z as AnyObject, "acc_x": acc_x as AnyObject, "acc_y": acc_y as AnyObject, "acc_z": acc_z as AnyObject, "gyr_x": gyr_x as AnyObject, "gyr_y": gyr_y as AnyObject, "gyr_z": gyr_z as AnyObject, "gra_x": gra_x as AnyObject, "gra_y": gra_y as AnyObject, "gra_z": gra_z as AnyObject, "mag_x": mag_x as AnyObject, "mag_y": mag_y as AnyObject, "mag_z": mag_z as AnyObject, "att_roll": att_roll as AnyObject, "att_pitch": att_pitch as AnyObject, "att_yaw": att_yaw as AnyObject, "delta_heading": delta_heading as AnyObject, "timestamps": timestamps as AnyObject]
    }
}

struct User: Encodable, Decodable {
    var _id: String
    var subject_id: String
    var name: String
    var yob: Int
    var height: Int //cm
    var weight: Int //kg
    var is_female: Bool
    var medical_conditions: String
    
    func parseHeaders() -> [String: AnyObject] {
        return ["subject_id": subject_id as AnyObject, "name": name as AnyObject, "yob": yob as AnyObject, "height": height as AnyObject, "weight": weight as AnyObject, "is_female": is_female as AnyObject, "medical_conditions": medical_conditions as AnyObject]
    }
}
