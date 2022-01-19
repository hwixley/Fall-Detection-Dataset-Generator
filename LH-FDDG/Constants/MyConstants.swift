//
//  MyConstants.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 06/07/2021.
//

import Foundation
import Firebase
import FirebaseFirestore
import PolarBleSdk

struct MyConstants {
    static var adls : [String] = []
    static var falls : [String] = []
    static var placements : [String] = []
    static let goalRecordings = 6
    static let goalSubjects = 40
    static var colorGradient : [UIColor] = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green]
    static let bold = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : UIColor.black] as [NSAttributedString.Key : Any]
    static let normal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : UIColor.black]
    static var recordingLength = 15.0
    static var fallTime = 10.0
    static var polarDeviceID = "9F8BF424"
    static var polarManager = PolarBleSdkManager()
    static var serverIP = "192.168.8.160"
    static var serverPort = "8081"
}


func getConstantData() {
    Firestore.firestore().collection("constants").document("constants").getDocument { docSnapshot, err in
        
        if err == nil && docSnapshot != nil {
            let data = docSnapshot!.data()!
            MyConstants.adls = data["ADLs"] as! [String]
            MyConstants.falls = data["fall-types"] as! [String]
            MyConstants.placements = data["phone-placement"] as! [String]
        } else {
            print(err!.localizedDescription)
        }
    }
}

func refreshAllStats() {
    if false {
        var statList = getDefaultStats()
        
        for action in MyConstants.adls {
            statList[action.replacingOccurrences(of: " ", with: "_") + "-no_fall"] = 0
            for fall in MyConstants.falls {
                statList[action.replacingOccurrences(of: " ", with: "_") + "-fall-" + fall.replacingOccurrences(of: " ", with: "_")] = 0
            }
        }
        
        Firestore.firestore().collection("stats").document("root").updateData(statList)
        Firestore.firestore().collection("subjects").document("0").collection("recordingStats").document("root").updateData(statList)
    }
}


func formatStat(action: String, fall: String) -> String {
    return action.replacingOccurrences(of: " ", with: "_") + (fall == "" ? "-no_fall" : ("-fall-" + fall.replacingOccurrences(of: " ", with: "_")))
}

func getDefaultStats() -> [String : Int] {
    var statList : [String : Int] = [:]
    
    for action in MyConstants.adls {
        statList[formatStat(action: action, fall: "")] = 0
        for fall in MyConstants.falls {
            statList[formatStat(action: action, fall: fall)] = 0
        }
    }
    
    return statList
}

func getSubjectStatsRecordings(subjectID: String, docData: [String: Any]) -> [RecordingInfo] {
    var recList : [RecordingInfo] = []
    
    for action in MyConstants.adls {
        recList.append(RecordingInfo(id: subjectID, action: action, includesFall: false, fallType: "", subjectId: subjectID, phonePlacement: "", numberOfRecordings: docData[formatStat(action: action, fall: "")] as! Int))
        
        for fall in MyConstants.falls {
            recList.append(RecordingInfo(id: subjectID, action: action, includesFall: true, fallType: fall, subjectId: subjectID, phonePlacement: "", numberOfRecordings: docData[formatStat(action: action, fall: fall)] as! Int))
        }
    }
    
    return recList
}

struct MyUser {
    static var subjectId : String = ""
}
