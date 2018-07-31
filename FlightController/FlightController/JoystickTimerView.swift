//
//  JoystickTimerView.swift
//  FlightController
//
//  Created by Matthew Territo on 7/30/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

class JoystickTimerViewController: UIViewController, NetworkManager, MotionManager {
    // MARK: NetworkManager protocol
    var networkManager: WebsocketManager?

    func networkManager(_ manager: WebsocketManager?) {
        networkManager = manager
    }

    // MARK: MotionManager protocol
    static var forceThreshold: CGFloat = 4.0

    var motionManager: CMMotionManager?
    var referenceAttitude: CMAttitude!
    var currentAttitude: CMAttitude?

    func motionManager(_ manager: CMMotionManager?) {
        motionManager = manager
    }

    func referenceAttitude(_ reference: CMAttitude?) {
        referenceAttitude = reference
    }

    func startUpdates() {
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

    func stopUpdates() {
        guard let motionManager = motionManager, motionManager.isDeviceMotionActive else { return }

        // Release the reference attitude when motion disengaged
        motionManager.stopDeviceMotionUpdates()
        self.referenceAttitude = nil
        self.currentAttitude = nil
    }

    // MARK: Members
    static let JoystickImage = UIImage(named: "Joystick")
    static let refreshRate: TimeInterval = TimeInterval(1/10)
    var touchData: Set<JoystickTouch> = []
    var senderTimer: Timer?
    let leftStick: UIImageView = UIImageView(image: JoystickImage)
    let rightStick: UIImageView = UIImageView(image: JoystickImage)
    var hasForce: Bool = false


    // MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isMultipleTouchEnabled = true
        view.addSubview(leftStick)
        view.addSubview(rightStick)

        //senderTimer = Timer.scheduledTimer(timeInterval: JoystickTimerViewController.refreshRate, target: self, selector: #selector(handleTouches), userInfo: nil, repeats: true)

        senderTimer = Timer.scheduledTimer(withTimeInterval: JoystickTimerViewController.refreshRate, repeats: true, block: {_ in
            if (!self.touchData.isEmpty) {
                self.handleTouches()
            }
        })
        resetJoysticks()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? NetworkManager {
            destination.networkManager(networkManager)
        }
        if let destination = segue.destination as? MotionManager {
            destination.motionManager(motionManager)
        }
    }

//    // MARK: Handle Touches
//    @objc func handleTouches() {
//        // Must pop and replace to edit
//        for d in touchData {
//            var tmpTouch = touchData.remove(d)!
//            handleActiveStick(touch: &tmpTouch)
//            touchData.update(with: tmpTouch)
//        }
//
//        if ((touchData.filter { $0.isDeep }).isEmpty) {
//            hasForce = false
//            stopUpdates()
//        }
//    }


    // MARK: Handle Touches
    func handleTouches() {
        // Must pop and replace to edit
        for d in touchData {
            var tmpTouch = touchData.remove(d)!
            handleActiveStick(touch: &tmpTouch)
            touchData.update(with: tmpTouch)
        }

        if ((touchData.filter { $0.isDeep }).isEmpty) {
            hasForce = false
            stopUpdates()
        }
    }

    func handleActiveStick(touch: inout JoystickTouch) {
        let midX = (view.window?.bounds.midX)!
        if (touch.force < JoystickTimerViewController.forceThreshold) {
            if (!touch.wasDeep) {
                touch.isDeep = false
            }
        } else {
            if (!touch.wasDeep) {
                var notif: UINotificationFeedbackGenerator! = UINotificationFeedbackGenerator()
                notif.notificationOccurred(.success)
                touch.wasDeep = true
                touch.isDeep = true
                notif = nil
            }
        }

        if (touch.isDeep) {
            if (!hasForce) {
                hasForce = true
                startUpdates()
            }
        }
        touch.startLocation.x < midX ? processLeftStick(touch: touch) : processRightStick(touch: touch)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let j = JoystickTouch(touch: t, startLocation: t.location(in: t.view))
            touchData.insert(j)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let midX = (view.window?.bounds.midX)!
        for d in touchData {
            if(touches.contains(d.touch)) {
                d.startLocation.x < midX ? resetLeftStick() : resetRightStick()
                touchData.remove(d)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
    }

    func sendData(touch: JoystickTouch, type: StickType) {
        guard let socket = networkManager?.socket else { return }

        if socket.isConnected {

            var payload = OpenSpaceNavigationPayload()

            let r = touch.remap(value: touch.distance)
            let dx = Double(r.x)
            let dy = Double(r.y)

            // Handle joystick location
            switch type {
            case StickType.Left:
                payload.globalRollX = -dx
                payload.zoomOut = dy
                break
            case StickType.Right:
                payload.orbitX = dx
                payload.orbitY = dy
                break
            default:
                break
            }

            // Handle deep press
            if touch.isDeep {
                switch type {
                case StickType.Left:
                    payload.panY = currentAttitude?.roll
                    if (payload.panY != nil) {
                        payload.panY! /= 10
                    }
                    break
                case StickType.Right:
                    break
                default:
                    break
                }
            }

            //payload.threshold(t: 0.005)

            if(!payload.isEmpty()) {
                //payload.remap(low: -0.07, high: 0.07)
                networkManager?.write(data: OpenSpaceNavigationSocket(topic:1, payload: payload))
            }
        }

    }

    // MARK: Stick handling
    func processLeftStick(touch: JoystickTouch) {
        leftStick.center = touch.location
        sendData(touch: touch, type: StickType.Left)
    }

    func processRightStick(touch: JoystickTouch) {
        rightStick.center = touch.location
        sendData(touch: touch, type: StickType.Right)
    }

    func resetJoysticks() {
        resetStick(type: StickType.All)
    }

    func resetLeftStick() {
        resetStick(type: StickType.Left)
    }

    func resetRightStick() {
        resetStick(type: StickType.Right)
    }

    private func resetStick(type: StickType) {
        let duration = 0.085
        let damping = CGFloat(0.5)

        let w = view.bounds.width
        let h = view.bounds.height

        let left = CGPoint(x: w/4, y: h/2)
        let right = CGPoint(x: w - w/4, y: h/2)

        let leftAnimation = UIViewPropertyAnimator(duration: duration,
                                                   dampingRatio: damping,
                                                   animations: { [weak self] in
                                                    self?.leftStick.center = left
        })

        let rightAnimation = UIViewPropertyAnimator(duration: duration,
                                                    dampingRatio: damping,
                                                    animations: { [weak self] in
                                                        self?.rightStick.center = right
        })

        switch type {
        case StickType.Left:
            leftAnimation.startAnimation()
            break
        case StickType.Right:
            rightAnimation.startAnimation()
            break
        case StickType.All:
            leftAnimation.startAnimation()
            rightAnimation.startAnimation()
            break
        default:
            leftAnimation.startAnimation()
            rightAnimation.startAnimation()
            break
        }
    }

    func reset() {
        touchData.removeAll()
        resetJoysticks()
    }
}
