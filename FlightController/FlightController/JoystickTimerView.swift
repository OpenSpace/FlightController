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

class JoystickTimerViewController: ConfiguredViewController {

    // MARK: Members

    /// The Joystick image
    static let JoystickImage = UIImage(named: "Joystick")

    /// The sending rate
    static let refreshRate: TimeInterval = TimeInterval(1/120)

    /// A list of currently active touch objects
    var touchData: Set<JoystickTouch> = []

    var senderTimer: Timer?

    /// The left joystick object
    let leftStick: UIImageView = UIImageView(image: JoystickImage)

    /// The right joystick object
    let rightStick: UIImageView = UIImageView(image: JoystickImage)

    /// Whether deep press was engaged but not yet released
    var hasForce: Bool = false

    /// The configurations for the axes
    var config: OpenSpaceAxisConfiguration = OpenSpaceAxisConfiguration()

    /// Convenience alias for ConrollerAxes
    typealias AXIS = ControllerAxes


    // MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isMultipleTouchEnabled = true
        leftStick.tintColor = UIColor.black.withAlphaComponent(0.8)
        rightStick.tintColor = leftStick.tintColor
        view.addSubview(leftStick)
        view.addSubview(rightStick)
        view.backgroundColor = UIColor.black

        senderTimer = Timer.scheduledTimer(timeInterval: JoystickTimerViewController.refreshRate, target: self, selector: #selector(handleTouches), userInfo: nil, repeats: true)

//        senderTimer = Timer.scheduledTimer(withTimeInterval: JoystickTimerViewController.refreshRate, repeats: true, block: {_ in
//            if (!self.touchData.isEmpty) {
//                self.handleTouches()
//            }
//        })
        resetJoysticks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }

    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return [.all]
    }

    // MARK: Handle Touches
    @objc func handleTouches() {
        // Must pop and replace to edit
        for d in touchData {
            var tmpTouch = touchData.remove(d)!
            handleActiveStick(touch: &tmpTouch)
            touchData.update(with: tmpTouch)
        }

        if ((touchData.filter { $0.isDeep }).isEmpty) {
            hasForce = false
            stopMotionUpdates()
        }
    }


//    // MARK: Handle Touches
//    func handleTouches() {
//        // Must pop and replace to edit
//        for d in touchData {
//            var tmpTouch = touchData.remove(d)!
//            handleActiveStick(touch: &tmpTouch)
//            touchData.update(with: tmpTouch)
//        }
//
//        if ((touchData.filter { $0.isDeep }).isEmpty) {
//            hasForce = false
//            stopMotionUpdates()
//        }
//    }

    /**
     Performas all actions associated with an active touch (began, moved, or
     unmoved-but-active) The touch object may be altered to register new states.

     - Parameter touch: The JoystickTouch to process (inout)
     */
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
                startMotionUpdates()
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

    /**
     Generates and sends the websocket payload to OpenSpace.

     - Parameters:
     - touch: A JoystickTouch object
     - type: The StickType being handled
     */
    func sendData(touch: JoystickTouch, type: StickType) {
        guard let socket = networkManager?.socket else { return }

        if socket.isConnected {
            var values: [String: Double?] = [:]

            // Handle joystick location
            switch type {
            case StickType.Left:
                let xAxis = config.axisMapping[AXIS.StickLeftX]!
                let yAxis = config.axisMapping[AXIS.StickLeftY]!
                values[xAxis.motionName] = xAxis.attenuate(touch: touch, axis: false)
                values[yAxis.motionName] = yAxis.attenuate(touch: touch, axis: true)
                break
            case StickType.Right:
                let xAxis = config.axisMapping[AXIS.StickRightX]!
                let yAxis = config.axisMapping[AXIS.StickRightY]!
                values[xAxis.motionName] = xAxis.attenuate(touch: touch, axis: false)
                values[yAxis.motionName] = yAxis.attenuate(touch: touch, axis: true)
                break
            default:
                break
            }

            // Handle deep press
            if touch.isDeep {
                switch type {
                case StickType.Left:
                    if let roll = currentAttitude?.roll {
                        let rollAxis = config.axisMapping[AXIS.LeftRoll]!
                        values[rollAxis.motionName] = rollAxis.attenuate(CGFloat(roll))
                    }
                    break
                case StickType.Right:
                    break
                default:
                    break
                }
            }

            let inputState = OpenSpaceInputState(values: values)
            if(!inputState.isEmpty()) {

                let payload = OpenSpacePayload(inputState: inputState)
                let data = OpenSpaceData(topic: 1, payload: payload)
                networkManager?.write(data: data)
            }
        }
    }

    // MARK: Stick handling

    /**
     Process a touch using the left joystick's settings

     - Parameter touch: A JoystickTouch
     */
    func processLeftStick(touch: JoystickTouch) {
        leftStick.center = touch.location
        sendData(touch: touch, type: StickType.Left)
    }

    /**
     Process a touch using the right joystick's settings

     - Parameter touch: A JoystickTouch
     */
    func processRightStick(touch: JoystickTouch) {
        rightStick.center = touch.location
        sendData(touch: touch, type: StickType.Right)
    }

    /// Reset all joysticks
    func resetJoysticks() {
        resetStick(type: StickType.All)
    }

    /// Reset the left joystick
    func resetLeftStick() {
        resetStick(type: StickType.Left)
    }

    /// Reset the right joystick
    func resetRightStick() {
        resetStick(type: StickType.Right)
    }

    /**
     Reset a joystick

     - Parameter type: A StickType for the desired joystick
     */
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

    func updateJoystickTintFactor(_ f: CGFloat) {
        let col = leftStick.tintColor.withAlphaComponent(f)

        leftStick.tintColor = col
        rightStick.tintColor = col
    }

}
