//
//  JoystickView.swift
//  FlightController
//
//  Created by Matthew Territo on 7/19/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

/**
 Helper to subtract CGPoints

 - Paramters:
    - lhs: CGPoint
    - rhs: CGPoint

 - Returns: CGPoint of (lhs.x - rhs.x, lhs.y - rhs.y)
 */
func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

/**
 Helper to divide CGPoints

 - Paramters:
    - lhs: CGPoint
    - rhs: CGPoint

 - Returns: CGPoint of (lhs.x/rhs.x, lhs.y/rhs.y)

 */
func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x/rhs, y: lhs.y/rhs)
}

/// The types of sticks available to the controller
enum StickType: String {
    case Left
    case Right
    case All
    case None

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

    /// The original view of the touch
    var view: UIView {
        return touch.view!
    }

    /// Which stick this touch is associated with
    var stick: StickType = .None

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
