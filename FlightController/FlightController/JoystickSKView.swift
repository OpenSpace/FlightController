//
//  JoystickSKView.swift
//  FlightController
//
//  Created by Matthew Territo on 7/27/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import CoreMotion
import SpriteKit

class JoystickSKViewController: UIViewController, NetworkManager, MotionManager {
    // MARK: NetworkManager protocol
    var networkManager: WebsocketManager?

    func networkManager(_ manager: WebsocketManager?) {
        networkManager = manager
    }

    // MARK: MotionManager protocol
    var motionManager: CMMotionManager?
    var referenceAttitude: CMAttitude!
    var currentAttitude: CMAttitude?
    static var forceThreshold: CGFloat = 4.0

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

    // MARK: SpriteKit control
    var skView: SKView {
        return view as! SKView
    }

    // MARK: UIViewController overrides
    override func viewDidLoad() {
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true

        let scene = JoystickSKScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.delegate = self
        skView.presentScene(scene)
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

}

extension JoystickSKViewController: SKSceneDelegate {
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        if let joystickScene = scene as? JoystickSKScene {
            if (!joystickScene.touchData.isEmpty) {
                handleTouches(joystickScene)
            }
        }
    }

    private func handleTouches(_ scene: JoystickSKScene) {

        // Must pop and replace to edit
        for d in scene.touchData {
            var tmpTouch = scene.touchData.remove(d)!
            scene.handleActiveStick(touch: &tmpTouch)
            scene.touchData.update(with: tmpTouch)
        }

        if ((scene.touchData.filter { $0.isDeep }).isEmpty) {
            scene.hasForce = false
            stopUpdates()
        }
    }
}

class JoystickSKScene: SKScene {
    // MARK: Members
    var jsDelegate: JoystickSKViewController {
        return delegate as! JoystickSKViewController
    }

    var touchData: Set<JoystickTouch> = []
    let leftStick = SKSpriteNode(imageNamed: "Joystick")
    let rightStick = SKSpriteNode(imageNamed: "Joystick")
    var hasForce: Bool = false
        var config: OpenSpaceAxisConfiguration = OpenSpaceAxisConfiguration()

    typealias AXIS = ControllerAxes

    // MARK: SKScene overrides
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.darkGray
        addChild(leftStick)
        addChild(rightStick)
        resetJoysticks()
    }

    override func willMove(from view: SKView) {
        removeAllChildren()
    }

    // MARK: Handle Touches
    func handleActiveStick(touch: inout JoystickTouch) {
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
                    del.startUpdates()
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

    func sendData(touch: JoystickTouch, type: StickType) {
        guard let socket = jsDelegate.networkManager?.socket else { return }

        if socket.isConnected {

            var payload = OpenSpaceNavigationPayload()

//            let r = touch.remap(value: touch.distance)
//            let dx = Double(r.x)
//            let dy = Double(r.y)


            // Handle joystick location
            switch type {
            case StickType.Left:
                let xAxis = config.axisMapping[AXIS.StickLeftX]!
                let yAxis = config.axisMapping[AXIS.StickLeftY]!
                payload[xAxis.motionName] = xAxis.attenuate(touch: touch, axis: false)
                payload[yAxis.motionName] = yAxis.attenuate(touch: touch, axis: true)
                break
            case StickType.Right:
                let xAxis = config.axisMapping[AXIS.StickRightX]!
                let yAxis = config.axisMapping[AXIS.StickRightY]!
                payload[xAxis.motionName] = xAxis.attenuate(touch: touch, axis: false)
                payload[yAxis.motionName] = yAxis.attenuate(touch: touch, axis: true)
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
                            payload[rollAxis.motionName] = rollAxis.attenuate(CGFloat(roll))
                        }
                        break
                    case StickType.Right:
                        break
                    default:
                        break
                    }
                }
            }

            //payload.threshold(t: 0.005)

            if(!payload.isEmpty()) {
                //payload.remap(low: -0.07, high: 0.07)
                jsDelegate.networkManager?.write(data: OpenSpaceNavigationSocket(topic:1, payload: payload))
            }
        }

    }

    // MARK: Stick handling
    func processLeftStick(touch: JoystickTouch) {
        leftStick.removeAllActions()
        leftStick.position = touch.location
        leftStick.position.y = size.height - leftStick.position.y
        sendData(touch: touch, type: StickType.Left)
    }

    func processRightStick(touch: JoystickTouch) {
        rightStick.removeAllActions()
        rightStick.position = touch.location
        rightStick.position.y = size.height - rightStick.position.y
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
        case StickType.All:
            leftStick.run(leftAction)
            rightStick.run(rightAction)
            break
        default:
            leftStick.run(leftAction)
            rightStick.run(rightAction)
            break
        }
    }

    func reset() {
        touchData.removeAll()
        resetJoysticks()
    }
}
