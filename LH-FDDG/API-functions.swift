//
//  API-functions.swift
//  LH-FDDG
//
//  Created by Harry Wixley on 18/01/2022.
//

import Foundation
import Alamofire

let ip = "192.168.8.171"
let port = "8081"
let host = "http://" + ip + ":" + port

struct Recording {
    var _id: String
    var subject_id: String
    var fall_time: Float
    var fall_type: String
    var recording_duration: Float
    var ground_time: Float
    var p_ecg: [Float]
    var p_acc_x: [Float]
    var p_acc_y: [Float]
    var p_acc_z: [Float]
    var acc_x: [Float]
    var acc_y: [Float]
    var acc_z: [Float]
    var gyr_x: [Float]
    var gyr_y: [Float]
    var gyr_z: [Float]
    var gra_x: [Float]
    var gra_y: [Float]
    var gra_z: [Float]
    var mag_x: [Float]
    var mag_y: [Float]
    var mag_z: [Float]
    var att_roll: [Float]
    var att_pitch: [Float]
    var att_yaw: [Float]
    var delta_heading: [Float]
}

struct User {
    var _id: String
    var subject_id: String
    var name: String
    var age: Int
    var height: Float //cm
    var weight: Float //kg
    var is_female: Bool
    var medical_conditions: String
}

class APIFunctions {
    func fetchRecordings() {
        print("fetching user data...")
        AF.request(host + "/fetchRecordings").response { response in
            print(response.data ?? "null data")
            
            
            //print(JSONDecoder.decode(<#T##self: JSONDecoder##JSONDecoder#>))
            
            //let data = String(data: response.data!, encoding: .utf8)
        }
    }
}
