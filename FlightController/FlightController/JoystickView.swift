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

    var hashValue: Int {
        return touch.hashValue
    }

    init(touch: UITouch, startLocation: CGPoint) {
        self.touch = touch
        self.startLocation = startLocation
    }

    func location() -> CGPoint{
        return location(in: touch.view!)

    }

    func location(in: UIView) -> CGPoint {
        return touch.location(in: touch.view!)
    }

    func distance() -> CGPoint {
        return location() - startLocation
    }

    func remap(value: CGPoint) -> CGPoint {
        let screen = touch.view!.window!.bounds
        let rX = (screen.maxX - screen.minX)
        let rY = (screen.maxY - screen.minY)
        let vX = (value.x - screen.minX)
        let vY = (value.y - screen.minY)

        return CGPoint(
            x: lowX + vX * (highX - lowX) / rX,
            y: lowY + vY * (highY - lowY) / rY
        )
    }
}

class JoystickView: UIView {

    // Tracking touches
    var touchData: Set<JoystickTouch> = []
    lazy var socketManager: WebsocketManager = WebsocketManager.shared

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let j = JoystickTouch(touch: t, startLocation: t.location(in: self))
            touchData.insert(j)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let midX = window!.bounds.midX
        for d in touchData {
            if (touches.contains(d.touch)) {
                d.startLocation.x < midX ? processLeftStick(touch: d) : processRightStick(touch: d)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for d in touchData {
            if(touches.contains(d.touch)) {
                touchData.remove(d)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchData.removeAll()
    }


    func sendData(touch: JoystickTouch, type: String) {
        guard let socket = socketManager.socket else { return }

        if socket.isConnected {
            let distance = touch.distance()

            //let r = touch.remap(value: distance)
            let r = distance
            let dx = Double(r.x)
            let dy = Double(r.y)

            var payload = NavigationSocketPayload()

            switch type {
            case "left":
                payload.orbitX = dx
                payload.zoomOut = dy
                break
            case "right":
                payload.panX = dx
                payload.panY = dy
                break
            default:
                break
            }
            //payload.threshold(t: 0.005)

            if(!payload.isEmpty()) {
                //payload.remap(low: -0.07, high: 0.07)
                socketManager.write(data: NavigationSocket(topic:1, payload: payload))
            }
        }

    }

    func processLeftStick(touch: JoystickTouch) {
        sendData(touch: touch, type: "left")
    }

    func processRightStick(touch: JoystickTouch) {
        sendData(touch: touch, type: "right")
    }
}
