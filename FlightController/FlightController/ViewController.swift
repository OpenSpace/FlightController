//
//  ViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 5/23/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import CoreMotion
import simd

class ViewController: UIViewController {
    @IBOutlet weak var accel_x: UILabel!
    @IBOutlet weak var accel_y: UILabel!
    @IBOutlet weak var accel_z: UILabel!

    @IBOutlet weak var gyro_x: UILabel!
    @IBOutlet weak var gyro_y: UILabel!
    @IBOutlet weak var gyro_z: UILabel!

    var motionManager: CMMotionManager?

    lazy var tuio: TuioSender = TuioSender.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopUpdates()
    }

    func startUpdates() {
        guard let motionManager = motionManager, motionManager.isDeviceMotionAvailable else {
            setValueLabels(rollPitchYaw: [-1,-1,-1])
            return
        }
        let referenceAttitude = motionManager.deviceMotion?.attitude
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { deviceMotion, error in
            guard let deviceMotion = deviceMotion else { return }
            let attitude = double3([deviceMotion.attitude.roll, deviceMotion.attitude.pitch, deviceMotion.attitude.yaw])
            let gravity = double3([deviceMotion.gravity.x, deviceMotion.gravity.y, deviceMotion.gravity.z])
            self.setValueLabels(rollPitchYaw: attitude)
            self.setValueLabels(gravity: gravity)
        }
    }

    func stopUpdates() {
        guard let motionManager = motionManager, motionManager.isDeviceMotionActive else { return }

        motionManager.stopDeviceMotionUpdates()
    }

    func setValueLabels(rollPitchYaw: double3) {
        accel_x.text = String(format: "Roll: %+6.4f", rollPitchYaw[0])
        accel_y.text = String(format: "Pitch: %+6.4f", rollPitchYaw[1])
        accel_z.text = String(format: "Yaw: %+6.4f", rollPitchYaw[2])
    }

    func setValueLabels(gravity: double3) {
        gyro_x.text = String(format: "X: %+6.4f", gravity[0])
        gyro_y.text = String(format: "Y: %+6.4f", gravity[1])
        gyro_z.text = String(format: "Z: %+6.4f", gravity[2])
    }
}

