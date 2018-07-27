//
//  JoystickView.swift
//  FlightController
//
//  Created by Matthew Territo on 7/19/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x/rhs, y: lhs.y/rhs)
}

enum StickType: String {
    case Left
    case Right
    case All

    func name() -> String {
        return self.rawValue
    }
}

/**
 Object for tracking extra touch data
 */
struct JoystickTouch: Hashable {
    var lowX: CGFloat = -0.1
    var lowY: CGFloat = -0.1
    var highX: CGFloat = 0.1
    var highY: CGFloat = 0.1

    var touch: UITouch
    var startLocation: CGPoint = CGPoint()
    var isDeep: Bool = false

    var force: CGFloat {
        return touch.force
    }

    var hashValue: Int {
        return touch.hashValue
    }

    var distance: CGPoint {
        return location - startLocation
    }

    var location: CGPoint{
        return location(inView: touch.view!)
    }


    init(touch: UITouch, startLocation: CGPoint) {
        self.touch = touch
        self.startLocation = startLocation
    }

    func location(inView: UIView) -> CGPoint {
        return touch.location(in: inView)
    }

    func remap(value: CGPoint) -> CGPoint {
//        let screen = touch.view!.window!.bounds
//        let rX = (2*screen.maxX)// - -screen.minX)
//        let rY = (2*screen.maxY)// - screen.minY)
//        let vX = (value.x + screen.maxX)
//        let vY = (value.y + screen.maxX)
//
//        return CGPoint(
//            x: lowX + vX * (highX - lowX) / rX,
//            y: lowY + vY * (highY - lowY) / rY
//        )
        let factor:CGFloat = 1000
        return value/factor;
    }
}

class JoystickView: UIView, NetworkManager {

    // MARK: NetworkManager protocol
    var networkManager: WebsocketManager?

    func networkManager(_ manager: WebsocketManager?) {
        networkManager = manager
    }

    // MARK: Members
    var touchData: Set<JoystickTouch> = []

    // MARK: Outlets
    @IBOutlet weak var leftStick: UIImageView!
    @IBOutlet weak var rightStick: UIImageView!

    // MARK: Handle Touches
    private func handleActiveStick(touch: JoystickTouch) {
        let midX = window!.bounds.midX
        touch.startLocation.x < midX ? processLeftStick(touch: touch) : processRightStick(touch: touch)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let j = JoystickTouch(touch: t, startLocation: t.location(in: self))
            touchData.insert(j)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for d in touchData {
            if (touches.contains(d.touch)) {
                handleActiveStick(touch: d)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let midX = window!.bounds.midX
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
            let distance = touch.distance

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
        guard let win = self.window else { return }

        let duration = 0.3
        let damping: CGFloat = 0.5

        let left = CGPoint(x: win.bounds.maxX/4, y: win.bounds.maxY/2)
        let right = CGPoint(x:win.bounds.maxX - win.bounds.maxX/4, y: win.bounds.maxY/2)

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
