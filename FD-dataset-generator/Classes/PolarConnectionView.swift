//
//  PolarConnectionView.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 18/12/2021.
//

import SwiftUI

struct PolarConnectionView: View {
    @StateObject var bleSdkManager: PolarBleSdkManager = MyConstants.polarManager
    
    var body: some View {
        VStack {
            if bleSdkManager.bluetoothPowerOn {
                ScrollView(.vertical) {
                    VStack(spacing: 20) {
                        /*
                        Group {
                            if viewModel.broadcastEnabled {
                                Button("Listening broadcast", action: {viewModel.broadcastToggle()})
                            } else {
                                Button("Listen broadcast", action: {viewModel.broadcastToggle()})
                            }
                        }*/
                        Group {
                            switch bleSdkManager.deviceConnectionState {
                            case .disconnected:
                                Button("Connect", action: {bleSdkManager.connectToDevice()})
                                Button("Auto Connect", action: {bleSdkManager.autoConnect()})
                            case .connecting(let deviceId):
                                Button("Connecting \(deviceId)", action: {})
                                    .disabled(true)
                                //Button("Auto Connect", action: {})
                                    //.disabled(true)
                            case .connected(let deviceId):
                                Button("Disconnect \(deviceId)", action: {bleSdkManager.disconnectFromDevice()})
                                //Button("Auto Connect", action: {})
                                    //.disabled(true)
                            }
                            /*
                            if bleSdkManager.seachEnabled {
                                Button("Stop device scan", action: {bleSdkManager.searchToggle()})
                            } else {
                                Button("Scan devices", action: {bleSdkManager.searchToggle()})
                            }*/
                        }
                        /*
                        Group {
                            if viewModel.ecgEnabled {
                                Button("Stop ECG Stream", action: {viewModel.ecgToggle()})
                            } else {
                                Button("Start ECG Stream", action: {viewModel.ecgToggle()})
                            }
                            
                            if viewModel.accEnabled {
                                Button("Stop ACC Stream", action: {viewModel.accToggle()})
                            } else {
                                Button("Start ACC Stream", action: {viewModel.accToggle()})
                            }
                            
                            if viewModel.ppgEnabled {
                                Button("Stop PPG Stream", action: { viewModel.ppgToggle()})
                            } else {
                                Button("Start PPG Stream", action: {viewModel.ppgToggle()})
                            }
                            
                            if viewModel.ppiEnabled {
                                Button("Stop PPI Stream", action: {viewModel.ppiToggle()})
                            } else {
                                Button("Start PPI Stream", action: {viewModel.ppiToggle()})
                            }
                            
                            if viewModel.sdkModeEnabled {
                                Button("Disable SDK mode", action: { viewModel.sdkModeDisable()})
                            } else {
                                Button("Enable SDK mode", action: { viewModel.sdkModeEnable()})
                            }
                        }
                        
                        Group {
                            Button("Start H10 recording", action: { viewModel.startH10Recording()})
                            Button("Stop H10 recording", action: {viewModel.stopH10Recording()})
                            Button("H10 recording status", action: { viewModel.getH10RecordingStatus()})
                        }
                        
                        Group {
                            Button("Set time", action: { viewModel.setTime()})
                        }*/
                    }
                }.frame(maxWidth: .infinity)
            } else {
                Text("Bluetooth OFF")
                    .bold()
                    .foregroundColor(.red)
                Spacer()
            }
        }
    }
}

struct PolarConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        PolarConnectionView(bleSdkManager: MyConstants.polarManager)
    }
}
