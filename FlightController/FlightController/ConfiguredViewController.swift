//
//  ConfiguredViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 8/1/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import CoreMotion
import Starscream

//struct OpenSpacePayload:Decodable {
//    var payload: [String: AnyObject]
//}
//
//struct OpenSpaceTopic: Decodable {
//    var payload: OpenSpacePayload
//    var topic: Int
//}

class ConfiguredViewController: UIViewController, NetworkManager, MotionManager, OpenSpaceManager {

    var somethingInteresting: OpenSpaceInputState = OpenSpaceInputState(
        values: ["orbitX", 0.0001])

    // MARK: OpenSpaceManager protocol
    var focusNodes: [String : String?]?
    var allNodes: [String : String?]?

    var focusNodeNames: [String]?
    var allNodeNames: [String]?
    
    func focusNodes(_ nodes: [String : String?]?) {
        focusNodes = nodes
        focusNodeNames = focusNodes?.keys.sorted {
            return $0 < $1
            } ?? []
    }

    func allNodes(_ nodes: [String : String?]?) {
        allNodes = nodes
        allNodeNames = allNodes?.keys.sorted {
            return $0 < $1
            } ?? []
    }

    // MARK: NetworkManager protocol
    var networkManager: WebsocketManager?

    func networkManager(_ manager: WebsocketManager?) {
        networkManager = manager
    }

    // MARK: MotionManager Protocol
    var motionManager: CMMotionManager?
    var referenceAttitude: CMAttitude!
    var currentAttitude: CMAttitude?
    static var forceThreshold: CGFloat = 4.0

    func motionManager(_ manager: CMMotionManager?) {
        motionManager = manager
    }

    func referenceAttitude(_ reference: CMAttitude?) {
        referenceAttitude = reference
    }

    func startMotionUpdates() {
        guard let motionManager = motionManager, motionManager.isDeviceMotionAvailable else {
            return
        }

        //motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { deviceMotion, error in
            guard let deviceMotion = deviceMotion else { return }

            self.currentAttitude = deviceMotion.attitude

            // Store the reference attitude when motion mode is engaged
            if (self.referenceAttitude == nil) {
                self.referenceAttitude = self.currentAttitude!.copy() as! CMAttitude
            }

            self.currentAttitude!.multiply(byInverseOf: self.referenceAttitude)
        }
    }

    func stopMotionUpdates() {
        guard let motionManager = motionManager, motionManager.isDeviceMotionActive else { return }

        // Release the reference attitude when motion disengaged
        motionManager.stopDeviceMotionUpdates()
        self.referenceAttitude = nil
        self.currentAttitude = nil
    }

    // MARK: UIViewController overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? NetworkManager {
            destination.networkManager(networkManager)
        }
        if let destination = segue.destination as? MotionManager {
            destination.motionManager(motionManager)
        }
        if let destination = segue.destination as? OpenSpaceManager {
            destination.focusNodes(focusNodes)
            destination.allNodes(allNodes)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        networkManager?.delegate = self
    }

    func doSomethingInteresting() {
        networkManager?.write(data: OpenSpaceData(topic: 1, payload: OpenSpacePayload(inputState: somethingInteresting)))
    }
}

extension ConfiguredViewController: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocketClient) {
        print("Connected")

        let payload = OpenSpacePayload(type: .connect)
        let data = OpenSpaceData(topic: 1, payload: payload)
        networkManager?.write(data: data)

    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Disconnected")
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let json = try? WebsocketManager.decoder.decode(OpenSpaceData.self, from: text.data(using: .utf8)!) else {
            print("Could not decode message received from OpenSpace: \(text)")
            return
        }

        // Handle the different payload types
        if let connectPayload = json.payload.connect {
            focusNodes = connectPayload.focusNodes
            allNodes = connectPayload.allNodes
        }

        if let _ = json.payload.disconnect {
            networkManager?.disconnect()
            print("Disconneting...now!")
        }
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Data received")
    }
}

