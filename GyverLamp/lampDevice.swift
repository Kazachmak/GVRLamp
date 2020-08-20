//
//  lampDevice.swift
//  GyverLamp
//
//  Created by Максим Казачков on 19.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import Foundation
import Network
import UIKit

class UDPClient{
    
    var connection: NWConnection?
    
    
    //MARK:- UDP
    func connectToUDP(_ hostUDP: NWEndpoint.Host, _ portUDP: NWEndpoint.Port) {
        // Transmited message:
     
      let messageToUDP = "DEB"
        self.connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)
        self.connection?.stateUpdateHandler = { (newState) in
            //print("This is stateUpdateHandler:")
            switch (newState) {
                case .ready:
                    //print("State: Ready\n")
                    self.sendUDP(messageToUDP)
                    self.receiveUDP()
                case .setup: break
                    //print("State: Setup\n")
                case .cancelled: break
                    //print("State: Cancelled\n")
                case .preparing: break
                    //print("State: Preparing\n")
                default: break
                    //print("ERROR! State not defined!\n")
            }
        }

        self.connection?.start(queue: .global())
    }

    func sendUDP(_ content: Data) {
        self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    func sendUDP(_ content: String) {
      let contentToSendUDP = content.data(using: String.Encoding.utf8)
        self.connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                
               DispatchQueue.main.async { print("Data was sent to UDP") }
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    func receiveUDP() {
        self.connection?.receiveMessage { (data, context, isComplete, error) in
          if (isComplete) {
                
               DispatchQueue.main.async { print("Receive is complete") }
                if (data != nil) {
                    let backToString = String(decoding: data!, as: UTF8.self)
                    print("Received message: \(backToString)")
                  DispatchQueue.main.async { print(backToString) }
                  
                } else {
                    print("Data == nil")
                }
            }
        }
    
    }
    
    
}


class LampDevice {
    
    let hostIP: NWEndpoint.Host?
    let hostPort: NWEndpoint.Port?
    var connectionStatus: Bool?
    var powerStatus: Bool?
    
    init(hostIP:NWEndpoint.Host, hostPort: NWEndpoint.Port){
        self.hostIP = hostIP
        self.hostPort = hostPort
        powerStatus = false
        connectionStatus = false
    }
    
    static func scan() {
        guard let deviceIp = UIDevice.current.getWiFiAddress() else {
            print("Can`t get local ip adress. Emmiting 'onError'")

            return
        }

        let client = UDPClient()

        let mask = deviceIp.split(separator: ".")
        
        
        for i in 1 ... 255 {
            let lampIp = "\(mask[0]).\(mask[1]).\(mask[2]).\(i)"
            
            client.connectToUDP(NWEndpoint.Host.name(lampIp, nil), 8888)
       
        }
        
    }
    
}
