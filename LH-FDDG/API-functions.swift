//
//  API-functions.swift
//  LH-FDDG
//
//  Created by Harry Wixley on 18/01/2022.
//

import Foundation
import Alamofire

let host = "http://\(MyConstants.serverIP):\(MyConstants.serverPort)"

protocol DataDelegate {
    func fetchRecordings(recordings: String)
    func fetchUser(user: String)
}

struct Recording: Codable {
    var creation: String
    var _id: String
    //var subject_id: String
    //var fall_time: Double
    //var fall_type: String
    //var recording_duration: Double
    //var ground_time: Double
    var p_ecg: [Double]
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
}

struct User: Codable {
    var _id: String
    var name: String
    var age: Int
    var height: Float //cm
    var weight: Float //kg
    var is_female: Bool
    var medical_conditions: String
}

class APIFunctions {
    
    var delegate: DataDelegate?
    static let functions = APIFunctions()
    
    func fetchRecordings() {
        print("Fetching recordings...")
        
        AF.request(host + "/fetchRecordings").response { response in
            let data = String(data: response.data!, encoding: .utf8)
            self.delegate?.fetchRecordings(recordings: data!)
        }
    }
    
    func fetchUser(id: String) {
        print("Fetching user with id \(id)...")
        
        AF.request(host + "/fetchUser").response { response in
            let data = String(data: response.data!, encoding: .utf8)
            self.delegate?.fetchUser(user: data!)
        }
    }
    
    func createUser(user: User) {
        print("Creating user...")
    }
    
    func createRecording(recording: Recording) {
        print("Creating recording...")
    }
}
