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
import Starscream

struct NavigationSocket: Codable {
    static var threshold: Double = 0.3
    var topic: Int
    let type: String = "flightcontroller"
    var payload: NavigationSocketPayload
}

struct NavigationSocketPayload: Codable {
    var type: String = "inputState"
    var orbitX: Double? = nil
    var orbitY: Double? = nil
    var panX: Double? = nil
    var panY: Double? = nil
    var globalRollX: Double? = nil
    var globalRollY: Double? = nil
    var localRollX: Double? = nil
    var localRollY: Double? = nil
    var zoomIn: Double? = nil
    var zoomOut: Double? = nil

    init(orbitX: Double? = nil,      orbitY: Double? = nil,
         panX: Double? = nil,        panY: Double? = nil,
         globalRollX: Double? = nil, globalRollY: Double? = nil,
         localRollX: Double? = nil,  localRollY: Double? = nil,
         zoomIn: Double? = nil,      zoomOut: Double? = nil)
    {
        self.orbitX = orbitX
        self.orbitY = orbitY
        self.panX = panX
        self.panY = panY
        self.globalRollX = globalRollX
        self.globalRollY = globalRollY
        self.localRollX = localRollX
        self.localRollY = localRollY
        self.zoomIn = zoomIn
        self.zoomOut = zoomOut
    }

    init(type: String) {
        self.type = type
    }

    mutating func threshold(t: Double) {
        if orbitX != nil && abs(orbitX!) < t { orbitX = nil}
        if orbitY != nil && abs(orbitY!) < t { orbitY = nil}
        if panX != nil && abs(panX!) < t { panX = nil}
        if panY != nil && abs(panY!) < t { panY = nil}
        if globalRollX != nil && abs(globalRollX!) < t { globalRollX = nil}
        if globalRollY != nil && abs(globalRollY!) < t { globalRollY = nil}
        if localRollX != nil && abs(localRollX!) < t { localRollX = nil}
        if localRollY != nil && abs(localRollY!) < t { localRollY = nil}
        if zoomIn != nil && abs(zoomIn!) < t { zoomIn = nil}
        if zoomOut != nil && abs(zoomOut!) < t { zoomOut = nil}
    }

    mutating func remap(low: Double, high: Double)
    {
        if orbitX != nil && orbitX! > 0 { orbitX = high}
        if orbitY != nil && orbitY! > 0 { orbitY = high}
        if panX != nil && panX! > 0 { panX = high}
        if panY != nil && panY! > 0 { panY = high}
        if globalRollX != nil && globalRollX! > 0 { globalRollX = high}
        if globalRollY != nil && globalRollY! > 0 { globalRollY = high}
        if localRollX != nil && localRollX! > 0 { localRollX = high}
        if localRollY != nil && localRollY! > 0 { localRollY = high}
        if zoomIn != nil && zoomIn! > 0 { zoomIn = high}
        if zoomOut != nil && zoomOut! > 0 { zoomOut = high}

        if orbitX != nil && orbitX! < 0 { orbitX = low}
        if orbitY != nil && orbitY! < 0 { orbitY = low}
        if panX != nil && panX! < 0 { panX = low}
        if panY != nil && panY! < 0 { panY = low}
        if globalRollX != nil && globalRollX! < 0 { globalRollX = low}
        if globalRollY != nil && globalRollY! < 0 { globalRollY = low}
        if localRollX != nil && localRollX! < 0 { localRollX = low}
        if localRollY != nil && localRollY! < 0 { localRollY = low}
        if zoomIn != nil && zoomIn! < 0 { zoomIn = low}
        if zoomOut != nil && zoomOut! < 0 { zoomOut = low}
    }

    func isEmpty() -> Bool {
        return (
            (orbitX == nil || orbitX!.isZero)
            && (orbitY == nil || orbitY!.isZero)
            && (panX == nil || panX!.isZero)
            && (panY == nil || panY!.isZero)
            && (globalRollX == nil || globalRollX!.isZero)
            && (globalRollY == nil || globalRollY!.isZero)
            && (localRollX == nil || localRollX!.isZero)
            && (localRollY == nil || localRollY!.isZero)
            && (zoomIn == nil || zoomIn!.isZero)
            && (zoomOut == nil || zoomOut!.isZero)
        )
    }
}

class ViewController: UIViewController, WebSocketDelegate {
    @IBOutlet weak var accel_x: UILabel!
    @IBOutlet weak var accel_y: UILabel!
    @IBOutlet weak var accel_z: UILabel!
    @IBOutlet weak var socketHost: UITextField!

    var motionManager: CMMotionManager?
    var referenceAttitude: CMAttitude! = nil

    var _socket: WebSocket?

    let encoder = JSONEncoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        encoder.outputFormatting = .sortedKeys
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


    @IBAction
    func connectSocket() {
        let host = (socketHost.text ?? "").isEmpty ? socketHost.placeholder : socketHost.text

        _socket = WebSocket(url: URL(string: "ws://\(host!):8001")!)
        guard let socket = _socket else {return}
        socket.connect()

        guard let data = try? self.encoder.encode(NavigationSocket(topic:1,
            payload: NavigationSocketPayload(type: "connect"))) else {
            return
        }

        socket.write(string: String(data: data, encoding: .utf8)!)
    }

    @IBAction
    func disconnectSocket() {
        guard let socket = _socket else {return}
        guard let data = try? self.encoder.encode(NavigationSocket(topic:1,
            payload: NavigationSocketPayload(type: "disconnect"))) else {
            return
        }

        socket.write(string: String(data: data, encoding: .utf8)!)

        socket.disconnect()
    }

    func startUpdates() {

        guard let motionManager = motionManager, motionManager.isDeviceMotionAvailable else {
            setValueLabels(rollPitchYaw: [-1,-1,-1])
            return
        }
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

            guard let socket = self._socket else {return}
            if socket.isConnected {
                // Websocket payload
                var payload = NavigationSocketPayload(
                    orbitX: attitude.y
                    , globalRollX: attitude.z
                    , zoomOut: attitude.x)
                payload.threshold(t: 0.35)

                if(!payload.isEmpty()) {
                    payload.remap(low: -0.06, high: 0.06)
                    guard let data = try? self.encoder.encode(NavigationSocket(topic:1, payload: payload)) else {
                        return
                    }

                    socket.write(string: String(data: data, encoding: .utf8)!)
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

    // Mark: Starscream WebSocketDelegate
    func websocketDidConnect(socket: WebSocketClient) {
        print("Connected")
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Disconnected")
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Message")
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Data")
    }

}
