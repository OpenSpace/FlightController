//
//  JoystickViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 7/30/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

class JoystickViewController: OpenSpaceViewController {

    // MARK: Members

    /// The Joystick image
    static let JoystickImage = UIImage(named: "Joystick")

    /// The sending rate
    static let refreshRate: TimeInterval = TimeInterval(1.0/30.0)

    /// A list of currently active touch objects
    var touchData: Set<JoystickTouch> = []

    var senderTimer: Timer?

    /// The left joystick object
    let leftStick: UIImageView = UIImageView(image: JoystickImage)

    /// The right joystick object
    let rightStick: UIImageView = UIImageView(image: JoystickImage)

    /// Whether deep press was engaged but not yet released
    var hasForce: Bool = false

    /// The current banking
    var currentBank: Double = 0.0

    /// The degradation of the bank
    var bankDegrade: Double = 0.05

    /// The configurations for the axes
    var config: OpenSpaceAxisConfiguration = OpenSpaceAxisConfiguration()

    /// Convenience alias for ConrollerAxes
    typealias AXIS = ControllerAxes


    // MARK: UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isMultipleTouchEnabled = true
        JoystickViewController.JoystickImage?.withRenderingMode(.alwaysTemplate)
        leftStick.tintColor = UIColor.black.withAlphaComponent(0.2)
        rightStick.tintColor = leftStick.tintColor
        view.addSubview(leftStick)
        view.addSubview(rightStick)
        view.backgroundColor = UIColor.black
        resetJoysticks()

        // Carter settings
        config.axisMapping =
            [ ControllerAxes.StickLeftX:
                ControllerAxisSettings(motion: OpenSpaceMotions.GlobalRollX,
                                       invert: true,
                                       sensitivity: 0.0005,
                                       threshold: 0.075)
                , ControllerAxes.StickLeftY:
                    ControllerAxisSettings(motion: OpenSpaceMotions.ZoomOut,
                                           invert: false,
                                           sensitivity: 0.001,
                                           threshold: 0.005)
                , ControllerAxes.StickRightX:
                    ControllerAxisSettings(motion: OpenSpaceMotions.OrbitX,
                                           invert: false,
                                           sensitivity: 0.001,
                                           threshold: 0.05)
                , ControllerAxes.StickRightY:
                    ControllerAxisSettings(motion: OpenSpaceMotions.OrbitY,
                                           invert: false,
                                           sensitivity: 0.001,
                                           threshold: 0.05)
                , ControllerAxes.LeftRoll:
                    ControllerAxisSettings(motion: OpenSpaceMotions.PanY,
                                           invert: true,
                                           sensitivity: 0.1,
                                           threshold: 0.01)
//                , ControllerAxes.BothYaw:
//                    ControllerAxisSettings(motion: OpenSpaceMotions.GlobalRollX,
//                                           invert: true,
//                                           sensitivity: 0.1,
//                                           threshold: 0.05)
//                , ControllerAxes.BothRoll:
//                    ControllerAxisSettings(motion: OpenSpaceMotions.OrbitY,
//                                           invert: true,
//                                           sensitivity: 0.1,
//                                           threshold: 0.05)

        ]

//            NotificationCenter.default.addObserver(
//                forName: NSNotification.Name.UIScreenBrightnessDidChange,
//                object: nil,
//                queue: nil ) {
//                    (_) in
//                    self.updateJoystickTintFactor(1.0 - UIScreen.main.brightness * 0.8)
//            }
    }

    override func viewWillDisappear(_ animated: Bool) {
        senderTimer?.invalidate()
        super.viewWillDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()

        // Start a timer to send touch events from this view
        let timer = Timer(timeInterval: JoystickViewController.refreshRate, target: self, selector: #selector(tick), userInfo: nil, repeats: true)

        RunLoop.current.add(timer, forMode: .commonModes)
        timer.fire()
        senderTimer = timer
    }

    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return [.all]
    }

    // MARK: Handle Touches
    @objc func tick() {
        if (!touchData.isEmpty) {
            if(OpenSpaceManager.shared.autopilotEngaged) {
                disableAutopilot()
            }
            OpenSpaceManager.shared.lastInteractionTime = Date()
            handleTouches()
        } else if OpenSpaceManager.shared.shouldDoSomethingInteresting {
            if (!OpenSpaceManager.shared.autopilotEngaged && !OpenSpaceManager.shared.waitingForAutopilot) {
                doSomethingInteresting()
            }
        }
    }

    func handleTouches() {
        // Must pop and replace to edit
        var leftIsDeep = false
        var rightIsDeep = false
        for touch in touchData {
            var tmpTouch = touchData.remove(touch)!
            handleActiveStick(touch: &tmpTouch)
            touchData.update(with: tmpTouch)
            leftIsDeep = (touch.stick == .Left && touch.isDeep) || leftIsDeep
            rightIsDeep = (touch.stick == .Right && touch.isDeep) || rightIsDeep
        }

        var state = OpenSpaceInputState()
        if (leftIsDeep && rightIsDeep) {
            state.merge(processFlight())
        } else {

            // FIXME: This doesn't quite hit zero
            if (abs(currentBank) > bankDegrade) {
                let motion = OpenSpaceMotions.LocalRollX
                var inputState = OpenSpaceInputState()
                inputState[motion] = currentBank < 0.0 ? bankDegrade : -bankDegrade
                state.merge(inputState)
                currentBank -= currentBank > 0.0 ? bankDegrade : -bankDegrade
            } else {
                currentBank = 0.0
            }

            for touch in touchData {
                switch(touch.stick) {
                case .Left:
                    state.merge(processLeftStick(touch: touch), overwrite: true)
                    break
                case .Right:
                    state.merge(processRightStick(touch: touch), overwrite: true)
                    break
                default:
                    print("No stick recognized for this touch: \(touch.stick)")
                    break
                }
            }
        }
        // Merge all the data into a single message
        // Send it if not empty
        if (!state.isEmpty()) {
            sendData(state: state)
        }

        if ((touchData.filter { $0.isDeep }).isEmpty) {
            hasForce = false
            MotionManager.shared.stopMotionUpdates()
        }
    }

    func processFlight() -> OpenSpaceInputState {

        var inputState = OpenSpaceInputState()

        guard let attitude = MotionManager.shared.currentAttitude else {
            return inputState
        }
//
//        // Handle Yaw/Banking
//        let yawAxis = config.axisMapping[AXIS.BothYaw]!
//        let yaw = yawAxis.attenuate(CGFloat(attitude.yaw))
//        inputState[yawAxis.motion!] = yaw
//        inputState[OpenSpaceMotions.LocalRollX] = yaw
//        currentBank += yaw
//
//        // Handle Roll/Forward motion
//        if let rollAxis = config.axisMapping[AXIS.BothRoll] {
//            inputState[rollAxis.motion!] = rollAxis.attenuate(CGFloat(attitude.roll))
//        }
        return inputState
    }

    /**
     Performs all actions associated with an active touch (began, moved, or
     unmoved-but-active) The touch object may be altered to register new states.

     - Parameter touch: The JoystickTouch to process (inout)
     */
    func handleActiveStick(touch: inout JoystickTouch) {
        let midX = (touch.view.window?.bounds.midX)!
        touch.stick = touch.startLocation.x < midX ? .Left : .Right

        if (touch.force < MotionManager.shared.forceThreshold) {
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
                MotionManager.shared.startMotionUpdates()
                print("starting motion");
            }
        }
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

    func sendData(state: OpenSpaceInputState) {
        if NetworkManager.shared.isConnected {
            let payload = OpenSpacePayload(inputState: state)
            let data = OpenSpaceData(topic: 1, payload: payload)
            NetworkManager.shared.write(data: data)
        }
    }

    // MARK: Stick handling

    /**
     Generates the input state data from a joystick

     - Parameters:
     - touch: A JoystickTouch object
     - type: The StickType being handled
     */
    func getInputData(touch: JoystickTouch, type: StickType) -> OpenSpaceInputState {

        var inputState = OpenSpaceInputState()

        // Handle joystick location
        switch type {
        case StickType.Left:
            let xAxis = config.axisMapping[AXIS.StickLeftX]!
            let yAxis = config.axisMapping[AXIS.StickLeftY]!
            inputState[xAxis.motionName] = xAxis.attenuate(touch: touch, axis: false)
            inputState[yAxis.motionName] = yAxis.attenuate(touch: touch, axis: true)
            break
        case StickType.Right:
            let xAxis = config.axisMapping[AXIS.StickRightX]!
            let yAxis = config.axisMapping[AXIS.StickRightY]!
            inputState[xAxis.motionName] = xAxis.attenuate(touch: touch, axis: false)
            inputState[yAxis.motionName] = yAxis.attenuate(touch: touch, axis: true)
            break
        default:
            break
        }

        // Handle deep press
        if touch.isDeep {
            switch type {
            case StickType.Left:
                if let attitude = MotionManager.shared.currentAttitude {
                    let rollAxis = config.axisMapping[AXIS.LeftRoll]!
                    inputState[rollAxis.motionName] = rollAxis.attenuate(CGFloat(attitude.roll))
                }
                break
            case StickType.Right:
                break
            default:
                break
            }
        }
        return inputState
    }

    /**
     Process a touch using the left joystick's settings

     - Parameter touch: A JoystickTouch
     */
    func processLeftStick(touch: JoystickTouch) -> OpenSpaceInputState {
        leftStick.center = touch.location
        return getInputData(touch: touch, type: StickType.Left)
    }

    /**
     Process a touch using the right joystick's settings

     - Parameter touch: A JoystickTouch
     */
    func processRightStick(touch: JoystickTouch) -> OpenSpaceInputState {
        rightStick.center = touch.location
        return getInputData(touch: touch, type: StickType.Right)
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
        leftStick.tintColor = leftStick.tintColor.withAlphaComponent(f*0.8)
        rightStick.tintColor = leftStick.tintColor
    }

}
