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
    var subject_id: String
    var fall_time: Double
    var fall_type: String
    var recording_duration: Double
    var ground_time: Double
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
    
    /*func parseHeaders() -> [String: Any] {
        return ["subject_id": subject_id, "fall_time": String(fall_time), "fall_type": fall_type, "recording_duration": String(recording_duration), "ground_time": String(ground_time), "p_ecg": String(p_ecg), "p_acc_x": String(p_acc_x), "p_acc_y": String(p_acc_y), "p_acc_z": String(p_acc_z), "acc_x": String(acc_x), "acc_y": String(acc_y), "acc_z": String(acc_z), "gyr_x": String(gyr_x), "gyr_y": String(gyr_y), "gyr_z": String(gyr_z), "gra_x": String(gra_x), "gra_y": String(gra_y), "gra_z": String(gra_z), "mag_x": String(mag_x), "mag_y": String(mag_y), "mag_z": String(mag_z), "att_roll": String(att_roll), "att_pitch": String(att_pitch), "att_yaw": String(att_yaw), "delta_heading": String(delta_heading)]
    }*/
}

struct User: Encodable, Decodable {
    var _id: String
    var subject_id: String
    var name: String
    var age: Int
    var height: Int //cm
    var weight: Int //kg
    var is_female: Bool
    var medical_conditions: String
    
    func parseHeaders() -> [String: AnyObject] {
        return ["subject_id": subject_id as AnyObject, "name": name as AnyObject, "age": age as AnyObject, "height": height as AnyObject, "weight": weight as AnyObject, "is_female": is_female as AnyObject, "medical_conditions": medical_conditions as AnyObject]
    }
}

class APIFunctions {
    
    //var delegate: DataDelegate?
    static let functions = APIFunctions()
    
    func fetchRecordings() {
        print("Fetching recordings...")
        
        AF.request(host + "/fetchRecordings").response { response in
            let data = String(data: response.data!, encoding: .utf8)
            //self.delegate?.fetchRecordings(recordings: data!)
        }
    }
    
    func fetchUser(subject_id: String) -> User? {
        print("Fetching user with subject_id \(subject_id)...")
        var user: User? = nil
        
        AF.request(host + "/fetchUser", method: .get, encoding: URLEncoding.httpBody, headers: ["subject_id": subject_id]).response { response in
            let userData = String(data: response.data!, encoding: .utf8)
            
            do {
                user = try JSONDecoder().decode(User.self, from: userData!.data(using: .utf8)!)
            } catch {
                print("Failed to decode /fetchUser response")
            }
        }
        
        return user
    }
    
    func createUser(user: User) -> String {
        print("Creating user...")
        var id: String = ""
        
        var request = URLRequest(url: URL(string: host + "/createUser")!)
        request.method = .post
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: user.parseHeaders())
        
        AF.request(request).responseJSON { response in //host + "/createUser", method: .post, parameters: user, encoder: JSONParameterEncoder.default).response { response in
            switch response.result {
                
            case .failure(let error):
                print("Failed to perform /createUser request")
                print(error)
                
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print(responseString)
                }
                
            case .success(let response):
                print("Successfully performed /createUser request")
                print(response)
                
                /*let metaData = String(data: response.data!, encoding: .utf8)
                
                do {
                    id = try JSONDecoder().decode(String.self, from: metaData!.data(using: .utf8)!)
                    print(id)
                } catch {
                    print("Failed to decode /createUser response")
                }*/
            }
        }
        
        return id
    }
    
    func createRecording(recording: Recording) {
        print("Creating recording...")
    }
}
