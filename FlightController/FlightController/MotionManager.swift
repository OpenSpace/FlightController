//
//  MotionManager.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import CoreMotion

protocol MotionManager {
    /// The CMMotionManager object
    var motionManager: CMMotionManager? { get set }

    /// The reference attitude for calculations
    var referenceAttitude: CMAttitude! { get set }

    /// The current attitude
    var currentAttitude: CMAttitude? { get }

    /// A threshold for pressure sensitivity
    static var forceThreshold: CGFloat { get set }

    /**
     Set self.motionManager

     - Parameter manager: A CMMotionManager?
     */
    func motionManager(_ manager: CMMotionManager?)

    /**
     Set self.referenceAttitude

     - Parameter reference: A CMAttitude?
     */
    func referenceAttitude(_ reference: CMAttitude?)

    /// Setup and begin getting motion updates from self.motionManager
    func startMotionUpdates()

    /// Stop motion updates from self.motionManager
    func stopMotionUpdates()
}
