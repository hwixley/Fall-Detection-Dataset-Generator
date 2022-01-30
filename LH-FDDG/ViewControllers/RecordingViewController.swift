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
import FirebaseFirestore

class RecordingViewController: UIViewController {
    
    //MARK: Input Properties
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: View Properties
    @IBOutlet weak var dataStackView: UIStackView!
    @IBOutlet weak var hrContainerView: UIView!
    
    //MARK: Labels
    @IBOutlet weak var timerLabel: UILabel!
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
    var shouldStop = false
    var timer : Timer? = nil
    
    //MARK: Motion based Variables
    let motionManager = CMMotionManager()
    
    var lastHeading = -999.0
    
    //MARK: Fall based variables
    var numFalls = 0
    var fallTime = -1.0
    var groundTime = -1.0
    
    //MARK: Server variables
    var buffer = BufferAPI()
    var currChunk = RecordingChunk(recording_id: "", chunk_index: -1)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //General setup
        self.dataStackView.isHidden = true
        self.saveButton.isHidden = true
        self.hrContainerView.isHidden = true
        self.stopButton.isHidden = true
        self.stopButton.isHidden = true
        self.cancelButton.isHidden = true
        
        self.timerLabel.textColor = UIColor.black
        let timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
        
        self.currChunk = RecordingChunk(recording_id: self.buffer.postQueue!.meta._id, chunk_index: 0)
        
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
        MyConstants.polarManager.isRecording = false
    }

    @IBSegueAction func addPolarDataSUI(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: PolarDataView(bleSdkManager: MyConstants.polarManager))
    }
    
    //MARK: Actions
    
    @IBAction func clickFinishRecording(_ sender: UIButton) {
        //Add to global stats
        Firestore.firestore().collection("stats").document("root2").getDocument { docSnapshot, e in
            if e == nil && docSnapshot != nil {
                Firestore.firestore().collection("stats").document("root2").updateData(["num_recordings": docSnapshot!.data()!["num_recordings"] as! Int + 1, "total_duration": docSnapshot!.data()!["total_duration"] as! Int + Int(self.count), "num_falls": docSnapshot!.data()!["num_falls"] as! Int + self.numFalls])
            }
        }

        //Add to subject stats
        Firestore.firestore().collection("subjects").document(self.buffer.postQueue!.meta.subject_id).getDocument { docSnapshot, e in
            if e == nil && docSnapshot != nil {
                Firestore.firestore().collection("subjects").document(self.buffer.postQueue!.meta.subject_id).updateData(["num_recordings": docSnapshot!.data()!["num_recordings"] as! Int + 1, "total_duration": docSnapshot!.data()!["total_duration"] as! Int + Int(self.count), "num_falls": docSnapshot!.data()!["num_falls"] as! Int + self.numFalls])
            }
        }
        
        //Add recording
        self.buffer.sendRemainingChunks()

        self.performSegue(withIdentifier: "unwindToPrepareRecording", sender: self)
    }
    
    @IBAction func clickCancelRecording(_ sender: UIButton) {
        self.motionManager.stopDeviceMotionUpdates()
        self.isComplete = true
        self.count = 0
        self.isRecording = false
        self.performSegue(withIdentifier: "unwindToPrepareRecording", sender: self)
    }
    
    @IBAction func clickStopRecording(_ sender: UIButton) {
        if (round(self.count*100)/100).truncatingRemainder(dividingBy: 1) == 0 {
            stopRecording()
        } else {
            self.shouldStop = true
        }
    }
    
    
    //MARK: Private Methods
    
    func stopRecording() {
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
        MyConstants.polarManager.isLive = false

        self.saveButton.isHidden = false
        self.stopButton.isHidden = true
        self.cancelButton.isHidden = false
    }
    
    
    @objc func updateTimer() {
        if !self.isComplete {
            if self.isRecording {
                self.storeData()
                
                // Push chunk
                if self.count > 4 && (round(self.count*100)/100).truncatingRemainder(dividingBy: 5) == 0 {
                    self.buffer.pushOntoQueue(chunk: self.currChunk)
                    self.currChunk = RecordingChunk(recording_id: self.currChunk.recording_id, chunk_index: self.currChunk.chunk_index + 1)
                }
                
                // Check for falls
                if self.fallTime != -1 && round(self.count*100)/100 >= self.fallTime {
                    if round(self.count*100)/100 == self.fallTime {
                        AudioServicesPlayAlertSound(SystemSoundID(1322))
                        self.numFalls += 1
                    } else {
                        self.currChunk.labels.append(true)
                    }
                    
                    if round(self.count*100)/100 == self.groundTime {
                        AudioServicesPlayAlertSound(SystemSoundID(1321))
                        self.fallTime = -1.0
                        self.groundTime = -1.0
                    }
                    
                // If no falls set the fallTime and groundTime
                } else {
                    self.currChunk.labels.append(false)
                    self.fallTime = self.count + Double([8,9,9,10,10,11,11,11,12][Int.random(in: 0...8)])
                    self.groundTime = self.fallTime + Double([2,2,3,3,3,3,3,4,4,4,4,5,5,5,6,6,7,7,8][Int.random(in: 0...18)])
                }
                
                // Checks if recording should be stopped
                if self.shouldStop && (round(self.count*100)/100).truncatingRemainder(dividingBy: 1) == 0 {
                    if self.currChunk.labels.count > 0 {
                        self.buffer.pushOntoQueue(chunk: self.currChunk)
                    }
                    self.buffer.postQueue!.meta.recording_duration = self.count
                    
                    stopRecording()
                } else {
                    self.count += 0.1
                    self.timerLabel.text = String(Double(round(1000*count)/1000)) + " s"
                }
            
            // Recording about to start
            } else if self.count >= 0.1 {
                self.count = self.count - 0.1
                self.timerLabel.text = "Recording starting in...\n " + String(Int(floor(count)))
                MyConstants.polarManager.isLive = true
            
            // Recording starts
            } else {
                MyConstants.polarManager.isRecording = true
                AudioServicesPlayAlertSound(SystemSoundID(1113))
                self.count = 0
                self.isRecording = true
                self.dataStackView.isHidden = false
                self.hrContainerView.isHidden = false
                self.stopButton.isHidden = false
                self.timerLabel.textColor = UIColor.systemRed
                self.timerLabel.text = String(Double(round(1000*count)/1000)) + " s"
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
                
                self.currChunk.acc_x.append(motionData.userAcceleration.x)
                self.currChunk.acc_y.append(motionData.userAcceleration.y)
                self.currChunk.acc_z.append(motionData.userAcceleration.z)
                
                self.currChunk.gyr_x.append(motionData.rotationRate.x)
                self.currChunk.gyr_y.append(motionData.rotationRate.y)
                self.currChunk.gyr_z.append(motionData.rotationRate.z)
                
                self.currChunk.mag_x.append(motionData.magneticField.field.x)
                self.currChunk.mag_y.append(motionData.magneticField.field.y)
                self.currChunk.mag_z.append(motionData.magneticField.field.z)
                
                self.currChunk.att_roll.append(motionData.attitude.roll)
                self.currChunk.att_pitch.append(motionData.attitude.pitch)
                self.currChunk.att_yaw.append(motionData.attitude.yaw)
                
                if self.lastHeading == -999 {
                    self.currChunk.delta_heading.append(0.0)
                    self.lastHeading = motionData.heading
                } else {
                    self.currChunk.delta_heading.append(motionData.heading - self.lastHeading)
                    self.lastHeading = motionData.heading
                }
                
                self.currChunk.gra_x.append(motionData.gravity.x)
                self.currChunk.gra_y.append(motionData.gravity.y)
                self.currChunk.gra_z.append(motionData.gravity.z)
                
                self.currChunk.appendPolarData(manager: MyConstants.polarManager)
            }
        } else {
            print("Stopping deviceMotion updates")
            self.motionManager.stopDeviceMotionUpdates()
        }
    }
}
