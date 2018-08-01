//
//  ConfiguredViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 8/1/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import CoreMotion

class ConfiguredViewController: UIViewController, NetworkManager, MotionManager {
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

}
