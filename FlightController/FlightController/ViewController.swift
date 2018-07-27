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

class ViewController: UIViewController, NetworkManager, MotionManager {
    var motionManager: CMMotionManager?
    var referenceAttitude: CMAttitude!
    var networkManager: WebsocketManager?

    //lazy var socketManager = WebsocketManager.shared

    @IBOutlet weak var accel_x: UILabel!
    @IBOutlet weak var accel_y: UILabel!
    @IBOutlet weak var accel_z: UILabel!
    @IBOutlet weak var socketHost: UITextField!

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
        stopUpdates()
        super.viewWillDisappear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? JoystickViewController {
            destination.networkManager = networkManager
        } else if let destination = segue.destination as? JoystickSKViewController {
            destination.networkManager = networkManager
        }
    }


    @IBAction
    func connectSocket() {
        let host = (socketHost.text ?? "").isEmpty ? socketHost.placeholder : socketHost.text

        networkManager?.addSocket(host: host!)
        networkManager?.connect()

        networkManager?.write(data: OpenSpaceNavigationSocket(topic:1,
            payload: OpenSpaceNavigationPayload(type: "connect")))

    }

    @IBAction
    func disconnectSocket() {
        networkManager?.write(data: OpenSpaceNavigationSocket(topic:1,
            payload: OpenSpaceNavigationPayload(type: "disconnect")))
        networkManager?.disconnect()
    }

    func startUpdates() {
        guard let motionManager = motionManager, motionManager.isDeviceMotionAvailable else {
            setValueLabels(rollPitchYaw: [-1,-1,-1])
            return
        }

        //motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { deviceMotion, error in
            guard let deviceMotion = deviceMotion else { return }

            let cur = deviceMotion.attitude

            // Store the reference attitude when motion mode is engaged
            if (self.referenceAttitude == nil) {
                self.referenceAttitude = cur.copy() as! CMAttitude
            }

            cur.multiply(byInverseOf: self.referenceAttitude)

            let attitude = double3([cur.roll, cur.pitch, cur.yaw])

            self.setValueLabels(rollPitchYaw: attitude)

            guard let socket = self.networkManager?.socket else {return}
            if socket.isConnected {
                // Websocket payload
                var payload = OpenSpaceNavigationPayload(
                    orbitX: attitude.y
                    , globalRollX: attitude.z
                    , zoomOut: attitude.x)
                payload.threshold(t: 0.35)

                if(!payload.isEmpty()) {
                    payload.remap(low: -0.07, high: 0.07)
                    self.networkManager?.write(data: OpenSpaceNavigationSocket(topic:1, payload: payload))
                }
            }
        }
    }

    func stopUpdates() {
        guard let motionManager = motionManager, motionManager.isDeviceMotionActive else { return }

        // Release the reference attitude when motion disengaged
        motionManager.stopDeviceMotionUpdates()
        self.referenceAttitude = nil
    }

    func setValueLabels(rollPitchYaw: double3) {
        accel_x.text = String(format: "Roll: %+6.4f", rollPitchYaw[0])
        accel_y.text = String(format: "Pitch: %+6.4f", rollPitchYaw[1])
        accel_z.text = String(format: "Yaw: %+6.4f", rollPitchYaw[2])
    }
}
