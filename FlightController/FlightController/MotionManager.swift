//
//  MotionManager.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import CoreMotion

protocol MotionManager {
    var motionManager: CMMotionManager? { get set }
    var referenceAttitude: CMAttitude! { get set }

    func motionManager(_ manager: CMMotionManager?)
    func referenceAttitude(_ reference: CMAttitude?)
}
