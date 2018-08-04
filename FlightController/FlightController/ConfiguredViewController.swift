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

struct OpenSpacePayload:Decodable {
    var payload: [String: AnyObject]
}

struct OpenSpaceTopic: Decodable {
    var payload: OpenSpacePayload
    var topic: Int
}
class ConfiguredViewController: UIViewController, NetworkManager, MotionManager {

    static var focusNodes: [String] = []

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
        if let destination = segue.destination as? ConfiguredViewController {
            // Send configuration along
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        networkManager?.delegate = self
    }
}

extension ConfiguredViewController: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocketClient) {
        print("Connected")
        networkManager?.write(data: OpenSpaceNavigationSocket(topic:1,
                                                              payload: OpenSpaceNavigationPayload(type: "connect")))

    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Disconnected")
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Message received: \(text)")
        guard let json = try? WebsocketManager.decoder.decode(OpenSpaceTopic.self, from: text.data(using: .utf8)!) else {
            print("Doink")
            print(text.data(using: .utf8)!)
            return
        }
        print(json.payload)
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Data received")
    }
}

