//
//  API-functions.swift
//  LH-FDDG
//
//  Created by Harry Wixley on 18/01/2022.
//

import Foundation
import Alamofire
import FirebaseFirestore

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
    
    
    
    
    func ping(completion: @escaping ((Bool) -> Void)) {
        print("Pinging server...")
        MyConstants.isServerReachable = nil
        MyConstants.isPingingServer = true
        
        var request = URLRequest(url: URL(string: getHost() + "/ping")!)
        request.method = .head
        
        AF.request(request).responseJSON { response in
            switch response.result {
                
            case .failure(let error):
                print("Failed to perform /ping request")
                print(error)
                MyConstants.isServerReachable = false
                MyConstants.isPingingServer = false
                completion(false)
                
            case .success(_):
                print("Successfully performed /ping request")
                MyConstants.isServerReachable = true
                completion(true)
            }
        }
    }
}
