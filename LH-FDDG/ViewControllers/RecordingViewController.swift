//
//  RecordingViewController.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 04/07/2021.
//

import UIKit
import SwiftUI
import AVFoundation
import CoreMotion

class RecordingViewController: UIViewController {
    
    //MARK: Input Properties
    @IBOutlet weak var saveButton: UIButton!
    
    //MARK: View Properties
    @IBOutlet weak var dataStackView: UIStackView!
    @IBOutlet weak var hrContainerView: UIView!
    
    //MARK: Labels
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var fallLabel: UILabel!
    @IBOutlet weak var accelerometerLabel: UILabel!
    @IBOutlet weak var gyroLabel: UILabel!
    @IBOutlet weak var magnetometerLabel: UILabel!
    @IBOutlet weak var attitudeLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var gravityLabel: UILabel!
    
    //MARK: Timer Variables
    var count = 4.0
    var isRecording = false
    var isComplete = false
    let timeLimit = MyConstants.recordingLength
    var fallTime = MyConstants.fallTime
    var timer : Timer? = nil
    var groundTime = Double([2,2,2,2,3,3,3,3,4,4,4,5,5,5,6,6,7,7,8][Int.random(in: 0...18)])

    //MARK: Segue Data
    var recordingInfo: RecordingInfo? = nil
    var segue = ""
    
    //MARK: Motion based Variables
    let motionManager = CMMotionManager()
    var accDataX : [Double] = []
    var accDataY : [Double] = []
    var accDataZ : [Double] = []
    var gyroDataX : [Double] = []
    var gyroDataY : [Double] = []
    var gyroDataZ : [Double] = []
    var magDataX : [Double] = []
    var magDataY : [Double] = []
    var magDataZ : [Double] = []
    var magDataAcc : [Double] = []
    var attDataRoll : [Double] = []
    var attDataPitch : [Double] = []
    var attDataYaw : [Double] = []
    var headingData : [Double] = []
    var gravDataX : [Double] = []
    var gravDataY : [Double] = []
    var gravDataZ : [Double] = []
    var timeData : [Double] = []
    
    var hrData : [UInt8] = []
    var hr_rrsData : [Int] = []
    var hr_rrs_peakData : [Int] = []
    var hr_rrsmsData : [Int] = []
    var hr_rrsms_peakData : [Int] = []
    var hr_contactData : [Bool] = []
    var ecgData : [Int32] = []
    var pAccDataX : [Int32] = []
    var pAccDataY : [Int32] = []
    var pAccDataZ : [Int32] = []
    
    var lastHeading = -999.0
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //General setup
        self.dataStackView.isHidden = true
        self.saveButton.isHidden = true
        self.hrContainerView.isHidden = true
        self.timerLabel.textColor = UIColor.black
        let timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
        
        if recordingInfo != nil {
            let actionTitle = NSMutableAttributedString(string: "Action: ", attributes: MyConstants.bold)
            let actionValue = NSAttributedString(string: self.recordingInfo!.action, attributes: MyConstants.normal)
            actionTitle.append(actionValue)
            self.actionLabel.attributedText = actionTitle
            
            let fallTitle = NSMutableAttributedString(string: "Fall: ", attributes: MyConstants.bold)
            let fallValue = NSAttributedString(string: self.recordingInfo!.includesFall == true ? self.recordingInfo!.fallType : "none", attributes: MyConstants.normal)
            fallTitle.append(fallValue)
            self.fallLabel.attributedText = fallTitle
        }
        
        if !self.recordingInfo!.includesFall {
            self.fallTime = -999
            self.groundTime = -999
        }
        
        //Motion setup
        DispatchQueue.global().async {

            DispatchQueue.main.async {
                if (self.motionManager.isDeviceMotionAvailable) {
                    self.motionManager.deviceMotionUpdateInterval = 0.1
                    self.motionManager.showsDeviceMovementDisplay = true
                }
            }
        }
    }
    

    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToSearchPage" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.viewControllers.first as! SearchSubjectsViewController
            vc.subjectID = self.recordingInfo!.subjectId
        }
    }

    @IBSegueAction func addPolarDataSUI(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: PolarDataView(bleSdkManager: MyConstants.polarManager))
    }
    
    //MARK: Actions
    
    @IBAction func clickFinishRecording(_ sender: UIButton) {
        //Add to global stats
        /*
        Firestore.firestore().collection("stats").document("root").getDocument { docSnapshot, e in
            
            if e == nil && docSnapshot != nil {
                Firestore.firestore().collection("stats").document("root").updateData([formatStat(action: self.recordingInfo!.action, fall: self.recordingInfo!.fallType): docSnapshot!.data()![formatStat(action: self.recordingInfo!.action, fall: self.recordingInfo!.fallType)] as! Int + 1])
            }
        }
         */

        //Add to subject stats
        /*
        Firestore.firestore().collection("subjects").document(self.recordingInfo!.subjectId).collection("recordingStats").document("root").getDocument { docSnapshot, e in
            
            if e == nil && docSnapshot != nil {
                Firestore.firestore().collection("subjects").document(self.recordingInfo!.subjectId).collection("recordingStats").document("root").updateData([formatStat(action: self.recordingInfo!.action, fall: self.recordingInfo!.fallType): docSnapshot!.data()![formatStat(action: self.recordingInfo!.action, fall: self.recordingInfo!.fallType)] as! Int + 1])
            }
        }*/

        let collectionName = formatStat(action: self.recordingInfo!.action, fall: self.recordingInfo!.fallType)
        
        //Add recording
        /*
        Firestore.firestore().collection("recordings").document("root").collection(collectionName).addDocument(data: ["subjectID": self.recordingInfo!.subjectId, "includesFall": self.recordingInfo!.includesFall, "fallType": self.recordingInfo!.fallType, "accelerometer-x": self.accDataX, "accelerometer-y": self.accDataY, "accelerometer-z": self.accDataZ, "gyroscope-x": self.gyroDataX, "gyroscope-y": self.gyroDataY, "gyroscope-z": self.gyroDataZ, "magnetometer-x": self.magDataX, "magnetometer-y": self.magDataY, "magnetometer-z": self.magDataZ, "magnetometer-acc": self.magDataAcc, "attitude-roll": self.attDataRoll, "attitude-pitch": self.attDataPitch, "attitude-yaw": self.attDataYaw, "heading": self.headingData, "gravity-x": self.gravDataX, "gravity-y": self.gravDataY, "gravity-z": self.gravDataZ, "recording-length": self.timeLimit, "fall-time": self.fallTime, "ground-time": self.groundTime, "hr-bpm": self.hrData, "hr-rrs": self.hr_rrsData, "hr-rrsms": self.hr_rrsmsData, "hr-rss-peak": self.hr_rrs_peakData, "hr-rssms-peak": self.hr_rrsms_peakData, "hr-contact": self.hr_contactData, "hr-ecg": self.ecgData, "hr-accelerometer-x": self.pAccDataX, "hr-accelerometer-y": self.pAccDataY, "hr-accelerometer-z": self.pAccDataZ])
         */

        self.performSegue(withIdentifier: self.segue, sender: self)
    }
    
    @IBAction func clickCancelRecording(_ sender: UIButton) {
        self.motionManager.stopDeviceMotionUpdates()
        self.isComplete = true
        self.count = 0
        self.isRecording = false
        self.performSegue(withIdentifier: self.segue, sender: self)
    }
    
    
    //MARK: Private Methods
    
    @objc func updateTimer() {
        if !self.isComplete {
            if self.isRecording {
                
                if self.recordingInfo!.includesFall {
                    if round(self.count*100)/100 == self.fallTime {
                        AudioServicesPlayAlertSound(SystemSoundID(1322))
                    }
                    
                    if round(self.count*100)/100 == (self.fallTime - self.groundTime) {
                        AudioServicesPlayAlertSound(SystemSoundID(1321))
                    }
                }
                
                if self.count >= 0.1 {
                    self.count = self.count - 0.1
                    self.timerLabel.text = String(Double(round(1000*count)/1000)) + " s"
                    
                    self.storeData()
                    
                } else {
                    AudioServicesPlayAlertSound(SystemSoundID(1114))
                    self.isComplete = true
                    self.timerLabel.text = "Recording complete!"
                    self.timerLabel.textColor = UIColor.black
                    self.motionManager.stopDeviceMotionUpdates()
                    self.dataStackView.isHidden = true
                    self.hrContainerView.isHidden = true
                    self.timer!.invalidate()
                    self.timer = nil
                    MyConstants.polarManager.isRecording = false
                    self.hrData = MyConstants.polarManager.hr
                    self.ecgData = MyConstants.polarManager.ecg
                    self.hr_rrsData = MyConstants.polarManager.hr_rrs
                    self.hr_rrs_peakData = MyConstants.polarManager.hr_rrs_peak
                    self.hr_rrsmsData = MyConstants.polarManager.hr_rrsms
                    self.hr_rrsms_peakData = MyConstants.polarManager.hr_rrsms_peak
                    self.hr_contactData = MyConstants.polarManager.contact
                    self.pAccDataX = MyConstants.polarManager.acc_x
                    self.pAccDataY = MyConstants.polarManager.acc_y
                    self.pAccDataZ = MyConstants.polarManager.acc_z
                    
                    print(self.hrData.count)
                    print(self.hr_rrsData.count)
                    print(self.hr_rrsmsData.count)
                    print(self.ecgData.count)
                    print(self.pAccDataX.count)
                    print(self.pAccDataY.count)
                    print(self.pAccDataZ.count)
                    print("non-polar length")
                    print(self.accDataX.count)
                    print()
                    /*print(self.pAccDataX)
                    print(self.ecgData)
                    print(self.hrData)
                    print(self.hr_rrsData)
                    print(self.hr_rrsmsData)
                    print(self.hr_rrs_peakData)
                    print(self.hr_rrsms_peakData)
                    print(self.hr_contactData)
                    print()*/
                    
                    if !(self.accDataX.count == self.timeData.count && self.accDataX.count == self.gyroDataX.count && self.timeData.count == self.gyroDataX.count && self.timeData.count == self.magDataX.count && self.magDataX.count == self.attDataRoll.count && self.attDataRoll.count == self.gravDataX.count && self.gravDataX.count == self.headingData.count && self.headingData.count == self.magDataAcc.count) {
                        print(self.accDataX.count)
                        print(self.gyroDataX.count)
                        print(self.magDataX.count)
                        print(self.timeData.count)
                        self.navigationItem.prompt = "Recording error: please try again"
                    } else {
                        self.saveButton.isHidden = false
                    }
                }
                
            } else {
                
                if self.count >= 0.1 {
                    self.count = self.count - 0.1
                    self.timerLabel.text = "Recording starting in...\n " + String(Int(floor(count)))
                } else {
                    AudioServicesPlayAlertSound(SystemSoundID(1113))
                    self.count = self.timeLimit
                    self.isRecording = true
                    self.dataStackView.isHidden = false
                    self.hrContainerView.isHidden = false
                    self.timerLabel.textColor = UIColor.systemRed
                    self.timerLabel.text = String(Double(round(1000*count)/1000)) + " s"
                    MyConstants.polarManager.isRecording = true
                }
            }
        }
    }
    
    
    //MARK: Movement Data Collection Methods
    
    func storeData() {
        if !self.isComplete && self.isRecording {
            
            self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue.main) { data, error in
                guard let motionData = data, error == nil else {
                    return
                }
                
                self.accelerometerLabel.text = "Accelerometer: X = " + String(format: "%.2f", motionData.userAcceleration.x) + "  Y = " + String(format: "%.2f", motionData.userAcceleration.y) + "  Z = " + String(format: "%.2f", motionData.userAcceleration.z)
                
                self.gyroLabel.text = "Gyroscope: X = " + String(format: "%.2f", motionData.rotationRate.x) + "  Y = " + String(format: "%.2f", motionData.rotationRate.y) + "  Z = " + String(format: "%.2f", motionData.rotationRate.z)
                
                self.magnetometerLabel.text = "Magnetometer: X = " + String(format: "%.2f", motionData.magneticField.field.x) + "  Y = " + String(format: "%.2f", motionData.magneticField.field.y) + "  Z = " + String(format: "%.2f", motionData.magneticField.field.z)
                
                self.attitudeLabel.text = "Attitude: Roll = " + String(format: "%.2f", motionData.attitude.roll) + "  Pitch = " + String(format: "%.2f", motionData.attitude.pitch) + "  Yaw = " + String(format: "%.2f", motionData.attitude.yaw)
                
                self.headingLabel.text = "Heading: " + String(format: "%.2f", motionData.heading)
                
                self.gravityLabel.text = "Gravity: X = " + String(format: "%.2f", motionData.gravity.x) + "  Y = " + String(format: "%.2f", motionData.gravity.y) + "  Z = " + String(format: "%.2f", motionData.gravity.z)
                
                
                self.accDataX.append(motionData.userAcceleration.x)
                self.accDataY.append(motionData.userAcceleration.y)
                self.accDataZ.append(motionData.userAcceleration.z)
                
                self.gyroDataX.append(motionData.rotationRate.x)
                self.gyroDataY.append(motionData.rotationRate.y)
                self.gyroDataZ.append(motionData.rotationRate.z)
                
                self.magDataX.append(motionData.magneticField.field.x)
                self.magDataY.append(motionData.magneticField.field.y)
                self.magDataZ.append(motionData.magneticField.field.z)
                self.magDataAcc.append(Double(motionData.magneticField.accuracy.rawValue))
                
                self.attDataRoll.append(motionData.attitude.roll)
                self.attDataPitch.append(motionData.attitude.pitch)
                self.attDataYaw.append(motionData.attitude.yaw)
                
                if self.lastHeading == -999 {
                    self.headingData.append(0.0)
                    self.lastHeading = motionData.heading
                } else {
                    self.headingData.append(motionData.heading - self.lastHeading)
                    self.lastHeading = motionData.heading
                }
                
                self.gravDataX.append(motionData.gravity.x)
                self.gravDataY.append(motionData.gravity.y)
                self.gravDataZ.append(motionData.gravity.z)
                
                self.timeData.append(self.count)
            }
        } else {
            print("Stopping deviceMotion updates")
            self.motionManager.stopDeviceMotionUpdates()
        }
    }
}
