//
//  JoystickSKView.swift
//  FlightController
//
//  Created by Matthew Territo on 7/27/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import SpriteKit

class JoystickSKViewController: ConfiguredViewController {
    // MARK: SpriteKit control
    var skView: SKView {
        return view as! SKView
    }

    var messageQueue: [OpenSpacePayload] = []

    // MARK: UIViewController overridesres
    override func viewDidLoad() {

        super.viewDidLoad()

        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true

        let scene = JoystickSKScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.delegate = self

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIScreenBrightnessDidChange,
            object: nil,
            queue: nil ) {
                (_) in
                scene.updateJoystickTintFactor(UIScreen.main.brightness * 0.8)
        }
        skView.presentScene(scene)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }

    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return [.all]
    }

    override var prefersStatusBarHidden: Bool {
        if #available(iOS 11.0, *) {
            return super.prefersStatusBarHidden
        }
        //return fullScreenMode || super.prefersStatusBarHidden
        return super.prefersStatusBarHidden
    }
}

extension JoystickSKViewController: SKSceneDelegate {
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        if let joystickScene = scene as? JoystickSKScene {
            if (!joystickScene.touchData.isEmpty) {
                lastInteractionTime = Date()
                var inputState =  OpenSpaceInputState()
                handleTouches(joystickScene, inputState: &inputState)
                messageQueue.append(OpenSpacePayload(inputState: inputState))
            } else if shouldDoSomethingInteresting() {
                doSomethingInteresting()
            }
        }
    }

    /**
     Handle interaction with the scene. Let's the scene handle each touch
     individually, then manages the aggregate settings and motion

     - Parameters:
        - scene: The active JoystickSKScene
     */
    private func handleTouches(_ scene: JoystickSKScene, inputState: inout OpenSpaceInputState) {

        var inputState = OpenSpaceInputState()
        // Must pop and replace to edit
        for d in scene.touchData {
            var tmpTouch = scene.touchData.remove(d)!
            scene.handleActiveStick(touch: &tmpTouch, inputState: &inputState)
            scene.touchData.update(with: tmpTouch)
        }

        if ((scene.touchData.filter { $0.isDeep }).isEmpty) {
            scene.hasForce = false
            stopMotionUpdates()
        }
    }
}

class JoystickSKScene: SKScene {
    // MARK: Members
    var jsDelegate: JoystickSKViewController {
        return delegate as! JoystickSKViewController
    }

    /// A list of currently active touch objects
    var touchData: Set<JoystickTouch> = []

    /// The left joystick object
    let leftStick = SKSpriteNode(imageNamed: "Joystick")

    /// The right joystick object
    let rightStick = SKSpriteNode(imageNamed: "Joystick")

    /// Whether deep press was engaged but not yet released
    var hasForce: Bool = false

    /// The configurations for the axes
    var config: OpenSpaceAxisConfiguration = OpenSpaceAxisConfiguration()

    /// Convenience alias for ConrollerAxes
    typealias AXIS = ControllerAxes

    // MARK: SKScene overrides
    override func didMove(to view: SKView) {

        let tint = UIColor.black
        let factor = CGFloat(UIScreen.main.brightness * 0.80)
        backgroundColor = SKColor.black
        leftStick.color = tint
        rightStick.color = tint
        updateJoystickTintFactor(factor)

        addChild(leftStick)
        addChild(rightStick)
        resetJoysticks()
    }

    override func willMove(from view: SKView) {
        removeAllChildren()
    }

    // MARK: Handle Touches
    func handleActiveStick(touch: inout JoystickTouch, inputState: inout OpenSpaceInputState) {
        let midX = size.width/2
        if let del = self.delegate as? MotionManager {
            if (touch.force < JoystickSKViewController.forceThreshold) {
                if (!touch.wasDeep) {
                    touch.isDeep = false
                }
            } else {
                if (!touch.wasDeep) {
                    var notif:UINotificationFeedbackGenerator! = UINotificationFeedbackGenerator()
                    notif.notificationOccurred(.success)
                    touch.wasDeep = true
                    touch.isDeep = true
                    notif = nil
                }
            }

            if (touch.isDeep) {
                if (!hasForce) {
                    hasForce = true
                    del.startMotionUpdates()
                }
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
        let midX = size.width/2
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
     Enqueues a payload
     */
    private func queueInput(payload: OpenSpacePayload) {

    }

    /**
     Generates and sends the websocket payload to OpenSpace.

     - Parameters:
        - touch: A JoystickTouch object
        - type: The StickType being handled
     */
    func sendData(touch: JoystickTouch, type: StickType) {
        guard let socket = jsDelegate.networkManager?.socket else { return }

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
                if let del = self.delegate as? MotionManager {
                    switch type {
                    case StickType.Left:
                        if let roll = del.currentAttitude?.roll {
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
            }

            let inputState = OpenSpaceInputState(values: values)
            if(!inputState.isEmpty()) {

                let payload = OpenSpacePayload(inputState: inputState)
                let data = OpenSpaceData(topic: 1, payload: payload)
                jsDelegate.networkManager?.write(data: data)
            }
        }
    }

    // MARK: Stick handling

    /**
     Process a touch using the left joystick's settings

     - Parameter touch: A JoystickTouch
     */
    func processLeftStick(touch: JoystickTouch) {
        leftStick.removeAllActions()
        leftStick.position = touch.location
        leftStick.position.y = size.height - leftStick.position.y
        sendData(touch: touch, type: StickType.Left)
    }

    /**
     Process a touch using the right joystick's settings

     - Parameter touch: A JoystickTouch
     */
    func processRightStick(touch: JoystickTouch) {
        rightStick.removeAllActions()
        rightStick.position = touch.location
        rightStick.position.y = size.height - rightStick.position.y
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

        let left = CGPoint(x: size.width/4, y: size.height/2)
        let right = CGPoint(x: size.width - size.width/4, y: size.height/2)

        let leftAction = SKAction.move(to: left, duration: duration)
        let rightAction = SKAction.move(to: right, duration: duration)

        switch type {
        case StickType.Left:
            leftStick.run(leftAction)
            break
        case StickType.Right:
            rightStick.run(rightAction)
            break
        default:
            leftStick.run(leftAction)
            rightStick.run(rightAction)
        }
    }

    /// Reset all touches and joysticks
    func reset() {
        touchData.removeAll()
        resetJoysticks()
    }

    func updateJoystickTintFactor(_ f: CGFloat) {
        let col = SKAction.colorize(withColorBlendFactor: f, duration: 1.0
        )
        leftStick.run(col)
        rightStick.run(col)
    }
}
