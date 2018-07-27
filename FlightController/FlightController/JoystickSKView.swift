//
//  JoystickSKView.swift
//  FlightController
//
//  Created by Matthew Territo on 7/27/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import SpriteKit

class JoystickSKViewController: UIViewController {
    var skView: SKView {
        return view as! SKView
    }

    var networkManager: WebsocketManager?

    override func viewDidLoad() {
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true

        let scene = JoystickSKScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.delegate = self
        skView.presentScene(scene)
    }
}

extension JoystickSKViewController: SKSceneDelegate {

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        if let joystickScene = scene as? JoystickSKScene {
            if (!joystickScene.touchData.isEmpty) {
                for d in joystickScene.touchData {
                    joystickScene.handleActiveStick(touch: d)
                }
            }
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
    func handleActiveStick(touch: JoystickTouch) {
        let midX = size.width/2
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
            let distance = touch.distance()
            let r = touch.remap(value: distance)
            //let r = distance
            let dx = Double(r.x)
            let dy = Double(r.y)

            var payload = OpenSpaceNavigationPayload()

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
        leftStick.position = touch.location()
        leftStick.position.y = size.height - leftStick.position.y
        sendData(touch: touch, type: StickType.Left)
    }

    func processRightStick(touch: JoystickTouch) {
        rightStick.removeAllActions()
        rightStick.position = touch.location()
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
