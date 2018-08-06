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

/// The types of sticks available to the controller
enum StickType: String {
    case Left
    case Right
    case All

    /// The value as a String
    var name: String {
        return self.rawValue
    }
}

/**
 Object for tracking touches and necessary data
 */
struct JoystickTouch: Hashable {
    /// The original UITouch object
    var touch: UITouch

    /// The location where the touch was first registered
    var startLocation: CGPoint = CGPoint()

    /// Is a force touch
    var isDeep: Bool = false

    /// Was a force touch previously
    var wasDeep: Bool = false

    /// The amount of force
    var force: CGFloat {
        return touch.force
    }

    /// The hashing value is the original touch's hash
    var hashValue: Int {
        return touch.hashValue
    }

    /// The distance from the touch's current location to where it started
    var distance: CGPoint {
        return location - startLocation
    }

    /// The current location of the touch in it's registered view
    var location: CGPoint{
        return location(inView: touch.view!)
    }

    /// The width of the touch's registered view
    var width: CGFloat {
        return touch.view!.bounds.width
    }

    /// The height of the touch's registered view
    var height: CGFloat {
        return touch.view!.bounds.height
    }

    /// Initalize with a UITouch and a CGPoint starting location
    init(touch: UITouch, startLocation: CGPoint) {
        self.touch = touch
        self.startLocation = startLocation
    }

    /**
     The location of the touch in a specified UIView

     - Parameter inView: The reference UIView

     - Returns: A CGPoint of the location
     */
    func location(inView: UIView) -> CGPoint {
        return touch.location(in: inView)
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
//        guard let socket = networkManager?.socket else { return }
//
//        if socket.isConnected {
//            let distance = touch.distance
//
//            let r = distance
//            let dx = Double(r.x)
//            let dy = Double(r.y)
//
//            var payload = OpenSpaceNavigationPayload()
//
//            switch type {
//            case StickType.Left:
//                payload.globalRollX = -dx
//                payload.zoomOut = dy
//                break
//            case StickType.Right:
//                payload.orbitX = dx
//                payload.orbitY = dy
//                break
//            default:
//                break
//            }
//            //payload.threshold(t: 0.005)
//
//            if(!payload.isEmpty()) {
//                //payload.remap(low: -0.07, high: 0.07)
//                networkManager?.write(data: OpenSpaceNavigationSocket(topic:1, payload: payload))
//            }
//        }

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
