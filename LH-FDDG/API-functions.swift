//
//  API-functions.swift
//  LH-FDDG
//
//  Created by Harry Wixley on 18/01/2022.
//

import Foundation
import Alamofire
import FirebaseFirestore

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

class APIFunctions {
    
    static let functions = APIFunctions()
    
    func getHost() -> String {
        return "http://\(MyConstants.serverIP):\(MyConstants.serverPort)"
    }
    
    func fetchRecordings() {
        print("Fetching recordings...")
        
        AF.request(getHost() + "/fetchRecordings").response { response in
            let data = String(data: response.data!, encoding: .utf8)
            //self.delegate?.fetchRecordings(recordings: data!)
        }
    }
    
    func fetchUser(subject_id: String) {
        print("Fetching user with subject_id \(subject_id)...")
        
        var request = URLRequest(url: URL(string: getHost() + "/fetchUser")!)
        request.method = .get
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(subject_id, forHTTPHeaderField: "subject_id")
        
        AF.request(request).responseJSON { response in
            switch response.result {
                
            case .failure(let error):
                print("Failed to perform /fetchUser request")
                print(error)
                
            case .success(let data):
                print("Successfully performed /fetchUser request")

                let json = String(data: response.data!, encoding: .utf8)!
                let jsonData = json.data(using: .utf8)!
                
                do {
                    let userList = try JSONDecoder().decode([User].self, from: jsonData)
                    if userList.count > 0 {
                        MyConstants.user = userList[0]
                        print("User with subject_id \(subject_id) found")
                    } else {
                        print("No user found with subject_id \(subject_id)")
                    }
                } catch {
                    print("Failed to decode /fetchUser response")
                }
            }
        }
    }
    
    func createUser(user: User) {
        print("Creating user...")
        
        var request = URLRequest(url: URL(string: getHost() + "/createUser")!)
        request.method = .post
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: user.parseHeaders())
        
        AF.request(request).responseJSON { response in
            switch response.result {
                
            case .failure(let error):
                print("Failed to perform /createUser request")
                print(error)
                
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print(responseString)
                }
                
            case .success(let data):
                print("Successfully performed /createUser request")
                
                if MyConstants.user != nil {
                    MyConstants.user!._id = data as! String
                    print("id: \(data as! String)")
                }
            }
        }
    }
    
    func createRecording(recording: Recording) {
        print("Creating recording...")
        
        var request = URLRequest(url: URL(string: getHost() + "/createRecording")!)
        request.method = .post
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: recording.parseHeaders())
        
        AF.request(request).responseJSON { response in
            switch response.result {
                
            case .failure(let error):
                print("Failed to perform /createRecording request")
                print(error)
                
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print(responseString)
                }
                
            case .success(let data):
                print("Successfully performed /createRecording request")
                print(data)
                
                //Add to global stats
                Firestore.firestore().collection("stats").document("root").getDocument { docSnapshot, e in
                    
                    if e == nil && docSnapshot != nil {
                        Firestore.firestore().collection("stats").document("root").updateData([formatStat(action: recording.action, fall: recording.fall_type): docSnapshot!.data()![formatStat(action: recording.action, fall: recording.fall_type)] as! Int + 1])
                    }
                }
                
                //Add to subject stats
                Firestore.firestore().collection("subjects").document(recording.subject_id).collection("recordingStats").document("root").getDocument { docSnapshot, e in
                    
                    if e == nil && docSnapshot != nil {
                        Firestore.firestore().collection("subjects").document(recording.subject_id).collection("recordingStats").document("root").updateData([formatStat(action: recording.action, fall: recording.fall_type): docSnapshot!.data()![formatStat(action: recording.action, fall: recording.fall_type)] as! Int + 1])
                    }
                }
            }
        }
    }
}
