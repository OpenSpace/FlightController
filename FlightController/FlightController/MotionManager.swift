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
    var motionManager: CMMotionManager? { get set }
    var referenceAttitude: CMAttitude! { get set }
    var currentAttitude: CMAttitude? { get }
    static var forceThreshold: CGFloat { get set }

    func motionManager(_ manager: CMMotionManager?)
    func referenceAttitude(_ reference: CMAttitude?)

    func startUpdates()
    func stopUpdates()
}
