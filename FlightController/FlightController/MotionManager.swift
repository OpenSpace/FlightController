//
//  MotionManager.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import CoreMotion

final class MotionManager {
    static let shared = MotionManager()

    /// The CMMotionManager object
    var manager: CMMotionManager?

    /// The reference attitude for calculations
    var referenceAttitude: CMAttitude!

    /// The current attitude
    var currentAttitude: CMAttitude?

    /// A threshold for pressure sensitivity
    var forceThreshold: CGFloat = 4.0


    private init() {
        manager = CMMotionManager()
    }
    /**
     Set self.motionManager

     - Parameter manager: A CMMotionManager?
     */
    func motionManager(_ manager: CMMotionManager?) {
        self.manager = manager
    }

    /**
     Set self.referenceAttitude

     - Parameter reference: A CMAttitude?
     */
    func referenceAttitude(_ reference: CMAttitude?) {
        self.referenceAttitude = reference
    }

    /// Setup and begin getting motion updates from self.motionManager
    func startMotionUpdates() {
        guard let motionManager = manager, motionManager.isDeviceMotionAvailable else {
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

    /// Stop motion updates from self.motionManager
    func stopMotionUpdates() {
        guard let motionManager = manager, motionManager.isDeviceMotionActive else { return }

        // Release the reference attitude when motion disengaged
        motionManager.stopDeviceMotionUpdates()
        referenceAttitude = nil
        currentAttitude = nil
    }
}
