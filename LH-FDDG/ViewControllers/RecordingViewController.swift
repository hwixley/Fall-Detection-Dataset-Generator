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
    /*
    let timeLimit = MyConstants.recordingLength
    var fallTime = MyConstants.fallTime*/
    var timer : Timer? = nil
    //var groundTime = Double([2,2,2,2,3,3,3,3,4,4,4,5,5,5,6,6,7,7,8][Int.random(in: 0...18)])

    //MARK: Segue Data
    //var recordingInfo: RecordingInfo? = nil
    var segue = ""
    
    //MARK: Motion based Variables
    let motionManager = CMMotionManager()
    var recording: Recording? = nil// = Recording(subject_id: "", fall_time: MyConstants.fallTime, fall_type: "", recording_duration: MyConstants.recordingLength, ground_time: Double([2,2,2,2,3,3,3,3,4,4,4,5,5,5,6,6,7,7,8][Int.random(in: 0...18)]), p_ecg: [], p_acc_x: [], p_acc_y: [], p_acc_z: [], acc_x: [], acc_y: [], acc_z: [], gyr_x: [], gyr_y: [], gyr_z: [], gra_x: [], gra_y: [], gra_z: [], mag_x: [], mag_y: [], mag_z: [], att_roll: [], att_pitch: [], att_yaw: [], delta_heading: [])
    /*var accDataX : [Double] = []
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
    var pAccDataZ : [Int32] = []*/
    
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
        
        if self.recording != nil {
            let actionTitle = NSMutableAttributedString(string: "Action: ", attributes: MyConstants.bold)
            let actionValue = NSAttributedString(string: self.recording!.action, attributes: MyConstants.normal)
            actionTitle.append(actionValue)
            self.actionLabel.attributedText = actionTitle
            
            let fallTitle = NSMutableAttributedString(string: "Fall: ", attributes: MyConstants.bold)
            let fallValue = NSAttributedString(string: self.recording!.fall_type != "" ? self.recording!.fall_type : "none", attributes: MyConstants.normal)
            fallTitle.append(fallValue)
            self.fallLabel.attributedText = fallTitle
        }
        
        if self.recording!.fall_type == "" {
            self.recording!.fall_time = -999
            self.recording!.ground_time = -999
            /*self.fallTime = -999
            self.groundTime = -999*/
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
            vc.subjectID = self.recording!.subject_id
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

        let collectionName = formatStat(action: self.recording!.action, fall: self.recording!.fall_type)
        
        //Add recording
        APIFunctions.functions.createRecording(recording: self.recording!)
        
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
                
                if self.recording!.fall_type != "" {
                    if round(self.count*100)/100 == self.recording!.fall_time {
                        AudioServicesPlayAlertSound(SystemSoundID(1322))
                    }
                    
                    if round(self.count*100)/100 == (self.recording!.fall_time - self.recording!.ground_time) {
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
                    self.recording!.p_hr = MyConstants.polarManager.hr
                    self.recording!.p_ecg = MyConstants.polarManager.ecg
                    self.recording!.p_hr_rss = MyConstants.polarManager.hr_rrs
                    self.recording!.p_hr_rss_peak = MyConstants.polarManager.hr_rrs_peak
                    self.recording!.p_hr_rssms = MyConstants.polarManager.hr_rrsms
                    self.recording!.p_hr_rssms_peak = MyConstants.polarManager.hr_rrsms_peak
                    //self.hr_contactData = MyConstants.polarManager.contact
                    self.recording!.p_acc_x = MyConstants.polarManager.acc_x
                    self.recording!.p_acc_y = MyConstants.polarManager.acc_y
                    self.recording!.p_acc_z = MyConstants.polarManager.acc_z
                    
                    print(self.recording!.p_hr.count)
                    print(self.recording!.p_hr_rss.count)
                    print(self.recording!.p_hr_rssms.count)
                    print(self.recording!.p_ecg.count)
                    print(self.recording!.p_acc_x.count)
                    print(self.recording!.p_acc_y.count)
                    print(self.recording!.p_acc_z.count)
                    print("non-polar length")
                    print(self.recording!.acc_x.count)
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
                    
                    if !(self.recording!.acc_x.count == self.recording!.timestamps.count && self.recording!.acc_x.count == self.recording!.gyr_x.count && self.recording!.timestamps.count == self.recording!.gyr_x.count && self.recording!.timestamps.count == self.recording!.mag_x.count && self.recording!.mag_x.count == self.recording!.att_roll.count && self.recording!.att_roll.count == self.recording!.gra_x.count && self.recording!.gra_x.count == self.recording!.delta_heading.count) {
                        print(self.recording!.acc_x.count)
                        print(self.recording!.gyr_x.count)
                        print(self.recording!.mag_x.count)
                        print(self.recording!.timestamps.count)
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
                    self.count = self.recording!.recording_duration
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
                
                
                self.recording!.acc_x.append(motionData.userAcceleration.x)
                self.recording!.acc_y.append(motionData.userAcceleration.y)
                self.recording!.acc_z.append(motionData.userAcceleration.z)
                
                self.recording!.gyr_x.append(motionData.rotationRate.x)
                self.recording!.gyr_y.append(motionData.rotationRate.y)
                self.recording!.gyr_z.append(motionData.rotationRate.z)
                
                self.recording!.mag_x.append(motionData.magneticField.field.x)
                self.recording!.mag_y.append(motionData.magneticField.field.y)
                self.recording!.mag_z.append(motionData.magneticField.field.z)
                //self.magDataAcc.append(Double(motionData.magneticField.accuracy.rawValue))
                
                self.recording!.att_roll.append(motionData.attitude.roll)
                self.recording!.att_pitch.append(motionData.attitude.pitch)
                self.recording!.att_yaw.append(motionData.attitude.yaw)
                
                if self.lastHeading == -999 {
                    self.recording!.delta_heading.append(0.0)
                    self.lastHeading = motionData.heading
                } else {
                    self.recording!.delta_heading.append(motionData.heading - self.lastHeading)
                    self.lastHeading = motionData.heading
                }
                
                self.recording!.gra_x.append(motionData.gravity.x)
                self.recording!.gra_y.append(motionData.gravity.y)
                self.recording!.gra_z.append(motionData.gravity.z)
                
                self.recording!.timestamps.append(self.count)
            }
        } else {
            print("Stopping deviceMotion updates")
            self.motionManager.stopDeviceMotionUpdates()
        }
    }
}
