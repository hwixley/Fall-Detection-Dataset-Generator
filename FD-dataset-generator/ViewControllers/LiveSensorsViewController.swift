//
//  LiveSensorsViewController.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 14/07/2021.
//

import UIKit
import SwiftUI
import CoreMotion
import PolarBleSdk
import RxSwift

class LiveSensorsViewController: UIViewController {
    
    //MARK: Labels
    @IBOutlet weak var accelerometerLabel: UILabel!
    @IBOutlet weak var gyroscopeLabel: UILabel!
    @IBOutlet weak var magnetometerLabel: UILabel!
    @IBOutlet weak var mAccLabel: UILabel!
    @IBOutlet weak var attitudeLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var gravityLabel: UILabel!
    @IBOutlet weak var ecgLabel: UILabel!
    
    
    //MARK: CoreMotion Vars
    let motionManager = CMMotionManager()
    var timer : Timer? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(LiveSensorsViewController.updateTimer), userInfo: nil, repeats: true)

        if (motionManager.isDeviceMotionAvailable) {
            self.motionManager.deviceMotionUpdateInterval = 0.1
            self.motionManager.showsDeviceMovementDisplay = true
        }
    }
    
    @objc func updateTimer() {
        self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue.main) { data, error in
            guard let motionData = data, error == nil else {
                return
            }
            
            self.accelerometerLabel.text = "X = " + String(format: "%.2f", motionData.userAcceleration.x) + "  Y = " + String(format: "%.2f", motionData.userAcceleration.y) + "  Z = " + String(format: "%.2f", motionData.userAcceleration.z)
            
            self.gyroscopeLabel.text = "X = " + String(format: "%.2f", motionData.rotationRate.x) + "  Y = " + String(format: "%.2f", motionData.rotationRate.y) + "  Z = " + String(format: "%.2f", motionData.rotationRate.z)
            
            self.magnetometerLabel.text = "X = " + String(format: "%.2f", motionData.magneticField.field.x) + "  Y = " + String(format: "%.2f", motionData.magneticField.field.y) + "  Z = " + String(format: "%.2f", motionData.magneticField.field.z)
            self.mAccLabel.text = "Accuracy = " + String(format: "%.2f", Double(motionData.magneticField.accuracy.rawValue))
            
            self.attitudeLabel.text = "Roll = " + String(format: "%.2f", motionData.attitude.roll) + "  Pitch = " + String(format: "%.2f", motionData.attitude.pitch) + "  Yaw = " + String(format: "%.2f", motionData.attitude.yaw)
            
            self.headingLabel.text = "Heading = " + String(format: "%.2f", motionData.heading)
            
            self.gravityLabel.text = "X = " + String(format: "%.2f", motionData.gravity.x) + "  Y = " + String(format: "%.2f", motionData.gravity.y) + "  Z = " + String(format: "%.2f", motionData.gravity.z)
        }
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if timer != nil {
            self.timer!.invalidate()
        }
        
        self.motionManager.stopDeviceMotionUpdates()
        self.motionManager.stopGyroUpdates()
        self.motionManager.stopAccelerometerUpdates()
        self.motionManager.stopMagnetometerUpdates()
    }
    
    @IBSegueAction func addPolarDataSUI(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: PolarDataView(bleSdkManager: MyConstants.polarManager))
    }
    
}
