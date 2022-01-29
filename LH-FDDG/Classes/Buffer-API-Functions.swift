//
//  Buffer-API-Functions.swift
//  LH-FDDG
//
//  Created by Harry Wixley on 28/01/2022.
//

import Foundation
import Alamofire
import FirebaseFirestore

class BufferAPI {
    var postQueue: PostQueue? = nil
    var postIndex = 0
    var lastChunkID = ""
    
    // Queue Functions
    func popFromQueue(idx: Int)  {
        print("popping from queue...")
        if idx < self.postQueue!.queue.count {
            self.postQueue!.queue.remove(at: idx)
        }
    }
    
    func pushOntoQueue(chunk: RecordingChunk) {
        print("push onto queue...")
        self.postQueue!.queue.append(chunk)
        self.postQueue!.meta.chunk_ids.append(chunk._id)
        
        postChunk()
    }
    
    func sendRemainingChunks() {
        print("send remaining chunks...")
        self.postIndex = 0
        
        while !self.postQueue!.queue.isEmpty {
            postChunk()
        }
        postMeta()
    }
    
    
    // API Functions
    func getHost() -> String {
        return "http://\(MyConstants.serverIP):\(MyConstants.serverPort)"
    }
    
    func fetchUser(subject_id: String) {
        print("Fetching user with subject_id \(subject_id)...")
        
        var request = URLRequest(url: URL(string: getHost() + "/fetchUser")!)
        request.method = .get
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(subject_id, forHTTPHeaderField: "subject_id")
        
        AF.request(request).responseString { response in
            switch response.result {
                
            case .failure(let error):
                print("Failed to perform /fetchUser request")
                print(error)
                
            case .success(_):
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
        
        AF.request(request).responseString { response in
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
                    MyConstants.user!._id = data
                    print("id: \(data)")
                }
            }
        }
    }
    
    func postChunk() {
        print("Posting recording chunk...")
        
        print(self.postQueue!.meta.chunk_ids.count)
        print(self.postIndex)
        
        if self.postIndex < self.postQueue!.queue.count {
            let chunk = self.postQueue!.queue[postIndex]
            let idx = postIndex
            
            if chunk._id != lastChunkID {
                self.postIndex = self.postIndex + 1
                
                var request = URLRequest(url: URL(string: getHost() + "/createChunk")!)
                request.method = .post
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try! JSONSerialization.data(withJSONObject: chunk.parseHeaders())
                
                AF.request(request).responseString { response in
                    switch response.result {
                        
                    case .failure(let error):
                        print("Failed to perform /createChunk request")
                        print(error)
                        
                        if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                            print(responseString)
                        }
                        
                    case .success(let data):
                        print("Successfully performed /createChunk request")
                        print(data)
                        self.lastChunkID = chunk._id
                        
                        self.popFromQueue(idx: idx)
                        if self.postIndex > 0 {
                            self.postIndex = self.postIndex - 1
                        }
                    }
                }
            } else {
                print("trying to post same chunk")
            }
        }
    }
    
    func postMeta() {
        print("Posting recording meta...")
        
        let meta = self.postQueue!.meta
        
        var request = URLRequest(url: URL(string: getHost() + "/createMeta")!)
        request.method = .post
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: meta.parseHeaders())
        
        AF.request(request).responseString { response in
            switch response.result {
                
            case .failure(let error):
                print("Failed to perform /createMeta request")
                print(error)
                
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print(responseString)
                }
                
            case .success(let data):
                print("Successfully performed /createMeta request")
                print(data)
            }
        }
    }
    
    func ping(completion: @escaping ((Bool) -> Void)) {
        print("Pinging server...")
        MyConstants.isServerReachable = nil
        MyConstants.isPingingServer = true
        
        var request = URLRequest(url: URL(string: getHost() + "/ping")!)
        request.method = .head
        
        AF.request(request).responseString { response in
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
