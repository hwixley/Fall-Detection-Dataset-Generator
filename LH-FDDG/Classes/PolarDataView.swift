//
//  PolarDataView.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 19/12/2021.
//

import SwiftUI

struct PolarDataView: View {
    @ObservedObject var bleSdkManager: PolarBleSdkManager = MyConstants.polarManager
    
    var body: some View {
        VStack {
            if bleSdkManager.bluetoothPowerOn && (bleSdkManager.deviceConnectionState == PolarBleSdkManager.ConnectionState.connected(MyConstants.polarDeviceID)) {
                ScrollView(.vertical) {
                    VStack(spacing: 4) {
                        Group {
                            
                            Text("HR: \(bleSdkManager.l_hr), \(bleSdkManager.l_hr_rrs), \(bleSdkManager.l_hr_rrsms)")
                            if bleSdkManager.ecgEnabled {
                                Text("ECG: \(bleSdkManager.l_ecg)")
                            } else {
                                Text("ECG: na")
                            }
                            if bleSdkManager.accEnabled {
                                Text("ACC: x=\(bleSdkManager.l_acc_x), y=\(bleSdkManager.l_acc_y), z=\(bleSdkManager.l_acc_z)")
                            } else {
                                Text("ACC: na")
                            }
                        }
                    }
                }.frame(maxWidth: .infinity)
            } else {
                Text("Bluetooth OFF or device not connected")
                    .bold()
                    .foregroundColor(.red)
                Spacer()
            }
        }
        .onAppear {
            if !bleSdkManager.ecgEnabled {
                bleSdkManager.ecgToggle()
            }
            if !bleSdkManager.accEnabled {
                bleSdkManager.accToggle()
            }
            bleSdkManager.isLive = true
            
            MyConstants.polarManager = bleSdkManager
            
        }
        .onDisappear {
            if bleSdkManager.ecgEnabled {
                bleSdkManager.ecgToggle()
            }
            if bleSdkManager.accEnabled {
                bleSdkManager.accToggle()
            }
            bleSdkManager.isLive = false
            
            MyConstants.polarManager = bleSdkManager
        }
    }
}

struct PolarDataView_Previews: PreviewProvider {
    static var previews: some View {
        PolarDataView(bleSdkManager: MyConstants.polarManager)
    }
}

