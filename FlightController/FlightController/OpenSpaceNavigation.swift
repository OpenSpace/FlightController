//
//  OpenSpaceNavigation.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

enum OpenSpaceMotions:String {
    case OrbitX = "orbitX"
    case OrbitY = "orbitY"
    case ZoomIn = "zoomIn"
    case ZoomOut = "zoomOut"
    case PanX = "panX"
    case PanY = "panY"
    case GlobalRollX = "globalRollX"
    case GlobalRollY = "globalRollY"
    case LocalRollX = "localRollX"
    case LocalRollY = "localRollY"
}

enum ControllerAxes {
    case StickLeftX
    case StickLeftY
    case StickRightX
    case StickRightY
    case LeftRoll
    case LeftPitch
    case LeftYaw
    case RightRoll
    case RightPitch
    case RightYaw
}

struct ControllerAxis {
    var motion: OpenSpaceMotions?
    var isInverted: Bool = false
    var sensitivity: Float = 1.0
    var threshold: Float = 0.0

    var multiplier: Float {
        return isInverted ? -sensitivity : sensitivity
    }

    var motionName: String {
        return motion!.rawValue
    }

    func attenuate(_ value: CGFloat) -> Double {
        let f = Float(value)
        return abs(f) < threshold ? 0.0 : Double(f * self.multiplier)
    }

    func attenuate(touch: JoystickTouch, axis: Bool) -> Double {
        let value = axis ? touch.distance.y : touch.distance.x
        let max = axis ? touch.height : touch.width

        return abs(value/max) < CGFloat(threshold) ? 0.0 : Double(value * CGFloat(self.multiplier))
    }

    init(motion: OpenSpaceMotions, invert: Bool, sensitivity: Float, threshold: Float) {
        self.motion = motion
        self.isInverted = invert
        self.sensitivity = sensitivity
        self.threshold = threshold
    }

    init(motion: OpenSpaceMotions, invert: Bool) {
        self.motion = motion
        self.isInverted = invert
    }
}

struct OpenSpaceAxisConfiguration {

    var axisMapping: [ControllerAxes:ControllerAxis] =
        [ ControllerAxes.StickLeftX:
            ControllerAxis(motion: OpenSpaceMotions.GlobalRollX,
                           invert: true,
                           sensitivity: 0.001,
                           threshold: 0.1)
        , ControllerAxes.StickLeftY:
            ControllerAxis(motion: OpenSpaceMotions.ZoomOut,
                           invert: false,
                           sensitivity: 0.001,
                           threshold: 0.05)
        , ControllerAxes.StickRightX:
            ControllerAxis(motion: OpenSpaceMotions.OrbitX,
                           invert: false,
                           sensitivity: 0.001,
                           threshold: 0.05)
        , ControllerAxes.StickRightY:
            ControllerAxis(motion: OpenSpaceMotions.OrbitY,
                           invert: false,
                           sensitivity: 0.001,
                           threshold: 0.05)
        , ControllerAxes.LeftRoll:
            ControllerAxis(motion: OpenSpaceMotions.PanY,
                           invert: false,
                           sensitivity: 0.1,
                           threshold: 0.05)
    ]

}

struct OpenSpaceNavigationSocket: Codable {
    static var threshold: Double = 0.3
    var topic: Int
    let type: String = "flightcontroller"
    var payload: OpenSpaceNavigationPayload
}

struct OpenSpaceNavigationPayload: Codable {
    var type: String = "inputState"
    var orbitX: Double? = nil
    var orbitY: Double? = nil
    var panX: Double? = nil
    var panY: Double? = nil
    var globalRollX: Double? = nil
    var globalRollY: Double? = nil
    var localRollX: Double? = nil
    var localRollY: Double? = nil
    var zoomIn: Double? = nil
    var zoomOut: Double? = nil

    init(orbitX: Double? = nil,      orbitY: Double? = nil,
         panX: Double? = nil,        panY: Double? = nil,
         globalRollX: Double? = nil, globalRollY: Double? = nil,
         localRollX: Double? = nil,  localRollY: Double? = nil,
         zoomIn: Double? = nil,      zoomOut: Double? = nil)
    {
        self.orbitX = orbitX
        self.orbitY = orbitY
        self.panX = panX
        self.panY = panY
        self.globalRollX = globalRollX
        self.globalRollY = globalRollY
        self.localRollX = localRollX
        self.localRollY = localRollY
        self.zoomIn = zoomIn
        self.zoomOut = zoomOut
    }

    init(type: String) {
        self.type = type
    }

    mutating func threshold(t: Double) {
        if orbitX != nil && abs(orbitX!) < t { orbitX = nil}
        if orbitY != nil && abs(orbitY!) < t { orbitY = nil}
        if panX != nil && abs(panX!) < t { panX = nil}
        if panY != nil && abs(panY!) < t { panY = nil}
        if globalRollX != nil && abs(globalRollX!) < t { globalRollX = nil}
        if globalRollY != nil && abs(globalRollY!) < t { globalRollY = nil}
        if localRollX != nil && abs(localRollX!) < t { localRollX = nil}
        if localRollY != nil && abs(localRollY!) < t { localRollY = nil}
        if zoomIn != nil && abs(zoomIn!) < t { zoomIn = nil}
        if zoomOut != nil && abs(zoomOut!) < t { zoomOut = nil}
    }

    mutating func remap(low: Double, high: Double)
    {
        if orbitX != nil && orbitX! > 0 { orbitX = high}
        if orbitY != nil && orbitY! > 0 { orbitY = high}
        if panX != nil && panX! > 0 { panX = high}
        if panY != nil && panY! > 0 { panY = high}
        if globalRollX != nil && globalRollX! > 0 { globalRollX = high}
        if globalRollY != nil && globalRollY! > 0 { globalRollY = high}
        if localRollX != nil && localRollX! > 0 { localRollX = high}
        if localRollY != nil && localRollY! > 0 { localRollY = high}
        if zoomIn != nil && zoomIn! > 0 { zoomIn = high}
        if zoomOut != nil && zoomOut! > 0 { zoomOut = high}

        if orbitX != nil && orbitX! < 0 { orbitX = low}
        if orbitY != nil && orbitY! < 0 { orbitY = low}
        if panX != nil && panX! < 0 { panX = low}
        if panY != nil && panY! < 0 { panY = low}
        if globalRollX != nil && globalRollX! < 0 { globalRollX = low}
        if globalRollY != nil && globalRollY! < 0 { globalRollY = low}
        if localRollX != nil && localRollX! < 0 { localRollX = low}
        if localRollY != nil && localRollY! < 0 { localRollY = low}
        if zoomIn != nil && zoomIn! < 0 { zoomIn = low}
        if zoomOut != nil && zoomOut! < 0 { zoomOut = low}
    }

    func isEmpty() -> Bool {
        return (
            (orbitX == nil || orbitX!.isZero)
                && (orbitY == nil || orbitY!.isZero)
                && (panX == nil || panX!.isZero)
                && (panY == nil || panY!.isZero)
                && (globalRollX == nil || globalRollX!.isZero)
                && (globalRollY == nil || globalRollY!.isZero)
                && (localRollX == nil || localRollX!.isZero)
                && (localRollY == nil || localRollY!.isZero)
                && (zoomIn == nil || zoomIn!.isZero)
                && (zoomOut == nil || zoomOut!.isZero)
        )
    }

    subscript(index: OpenSpaceMotions) -> Double? {
        get {
            return self[index.rawValue]
        }
        set (newValue) {
            self[index.rawValue] = newValue
        }
    }
    
    subscript(index: String) -> Double? {
        get {
            switch (index) {
            case OpenSpaceMotions.OrbitX.rawValue:
                return orbitX
            case OpenSpaceMotions.OrbitY.rawValue:
                return orbitY
            case OpenSpaceMotions.PanX.rawValue:
                return panX
            case OpenSpaceMotions.PanY.rawValue:
                return panY
            case OpenSpaceMotions.GlobalRollX.rawValue:
                return globalRollX
            case OpenSpaceMotions.GlobalRollX.rawValue:
                return globalRollY
            case OpenSpaceMotions.LocalRollX.rawValue:
                return localRollX
            case OpenSpaceMotions.LocalRollY.rawValue:
                return localRollY
            case OpenSpaceMotions.ZoomIn.rawValue:
                return zoomIn
            case OpenSpaceMotions.ZoomOut.rawValue:
                return zoomOut
            default:
                return nil
            }
        }
        set(newValue) {
            switch (index) {
            case OpenSpaceMotions.OrbitX.rawValue:
                orbitX = newValue
                break
            case OpenSpaceMotions.OrbitY.rawValue:
                orbitY = newValue
                break
            case OpenSpaceMotions.PanX.rawValue:
                panX = newValue
                break
            case OpenSpaceMotions.PanY.rawValue:
                panY = newValue
                break
            case OpenSpaceMotions.GlobalRollX.rawValue:
                globalRollX = newValue
                break
            case OpenSpaceMotions.GlobalRollX.rawValue:
                globalRollY = newValue
                break
            case OpenSpaceMotions.LocalRollX.rawValue:
                localRollX = newValue
                break
            case OpenSpaceMotions.LocalRollY.rawValue:
                localRollY = newValue
                break
            case OpenSpaceMotions.ZoomIn.rawValue:
                zoomIn = newValue
                break
            case OpenSpaceMotions.ZoomOut.rawValue:
                zoomOut = newValue
                break
            default:
                break
            }

        }
    }
}
