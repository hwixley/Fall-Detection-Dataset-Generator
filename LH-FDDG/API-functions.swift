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

struct Coord: Codable {
    var x: [Double] // x, roll
    var y: [Double]  // y, pitch
    var z: [Double]  // z, yaw
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
    /*
    private enum CodingKeys: String, CodingKey {
        case creation
        case _id
        case fall_time
        case fall_type
        case recording_duration
        case ground_time
        case p_ecg
        case p_acc_x
        case p_acc_y
        case p_acc_z
        case acc_x
        case acc_y
        case acc_z
        case gyr_x
        case gyr_y
        case gyr_z
        case gra_x
        case gra_y
        case gra_z
        case mag_x
        case mag_y
        case mag_z
        case att_roll
        case att_pitch
        case att_yaw
        case delta_heading
    }
    
    init(creation: NSDate, _id: String, fall_time: String) {
        <#statements#>
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        creation = try values.decode(NSDate, forKey: .creation)
        _id = try values.decode(String, forKey: ._id)
        fall_time = try values.decode(Float, forKey: .fall_time)
        fall_type = try values.decode(String, forKey: .fall_type)
        recording_duration = try values.decode(Float, forKey: .recording_duration)
        ground_time = try values.decode(Float, forKey: .ground_time)
        p_ecg = try values.decode([Float], forKey: .p_ecg)
    }*/
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
    
    var delegate: DataDelegate?
    static let functions = APIFunctions()
    
    func fetchRecordings() {
        print("fetching user data...")
        AF.request(host + "/fetchRecordings").response { response in
            print(response.data ?? "null data")
            
            let data = String(data: response.data!, encoding: .utf8)
            print(data)
            
            self.delegate?.fetchRecordings(recordings: data!)
            
            //print(JSONDecoder().decode([Recording].self, from: data!.data(using: .utf8)!))
        }
    }
}
