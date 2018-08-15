//
//  OpenSpaceNavigation.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

/// The motions available in OpenSpace mapped to their JSON object names
enum OpenSpaceMotions:String, Codable {
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

/// The control axes available in the app
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
    case BothRoll
    case BothPitch
    case BothYaw
}

/// Settings for an individual controller axis
struct ControllerAxisSettings {
    /// Which motion the axis maps to
    var motion: OpenSpaceMotions?

    /// Is inverted from normal mapping
    var isInverted: Bool = false

    /// Threshold magnitude before recognizing the axis has registered a value
    var threshold: Float = 0.0

    /// Sensitivity of the axis, applied after thresholding
    var sensitivity: Float = 1.0

    /// The value attenuator (inverted x sensitivity)
    var multiplier: Float {
        return isInverted ? -sensitivity : sensitivity
    }

    /// The JSON object name of the OpenSpace motion axis
    var motionName: String {
        return motion!.rawValue
    }

    /**
     Applies this controller's settings to remap the raw input UI value.
     First thresholds, then inverts and applies the sensitivity.

     - Parameter value: Raw input CGFloat value

     - Returns: 0.0 if under threshold, else attenuated Double value
     */

    func attenuate(_ value: CGFloat) -> Double {
        let f = Float(value)
        let t = f > 0 ? -threshold : threshold
        return abs(f) < threshold ? 0.0 : Double(f * self.multiplier) + Double(t)
    }

    /**
     Applies this controller's settings to remap the raw input UI touch object.
     First thresholds, then inverts and applies the sensitivity.

     - Parameters:
        - touch: A JoystickTouch object
        - axis: Calculate for x or y axis. Boolean where x = false, y = true

     - Returns: 0.0 if under threshold, else attenuated Double value
     */
    func attenuate(touch: JoystickTouch, axis: Bool) -> Double {
        let value = axis ? touch.distance.y : touch.distance.x
        let max = axis ? touch.height : touch.width


        let offset = value/max

        let t = offset > 0 ? -threshold : threshold
        return abs(value/max) < CGFloat(threshold) ? 0.0 : Double(value * CGFloat(self.multiplier)) + Double(t)
    }

    /// Init passing all values
    init(motion: OpenSpaceMotions, invert: Bool, sensitivity: Float, threshold: Float) {
        self.motion = motion
        self.isInverted = invert
        self.sensitivity = sensitivity
        self.threshold = threshold
    }

    /// Init using defaults for sensitvity (1.0) and threshold (0.0)
    init(motion: OpenSpaceMotions, invert: Bool) {
        self.motion = motion
        self.isInverted = invert
    }
}

/// A configuration for the axes
struct OpenSpaceAxisConfiguration {

    /**
     Dictionary mapping the available axes to a setting object.

     Default has:
        - LeftStickX -> GlobalRollX
        - LeftStickY -> ZoomOut
        - LeftRoll -> PanY
        - RightStickX -> OrbitX
        - RightStickY -> OrbitY
     */
    var axisMapping: [ControllerAxes:ControllerAxisSettings] =
        [ ControllerAxes.StickLeftX:
            ControllerAxisSettings(motion: OpenSpaceMotions.GlobalRollX,
                           invert: true,
                           sensitivity: 0.001,
                           threshold: 0.1)
        , ControllerAxes.StickLeftY:
            ControllerAxisSettings(motion: OpenSpaceMotions.ZoomOut,
                           invert: false,
                           sensitivity: 0.001,
                           threshold: 0.05)
        , ControllerAxes.StickRightX:
            ControllerAxisSettings(motion: OpenSpaceMotions.OrbitX,
                           invert: true,
                           sensitivity: 0.001,
                           threshold: 0.05)
        , ControllerAxes.StickRightY:
            ControllerAxisSettings(motion: OpenSpaceMotions.OrbitY,
                           invert: true,
                           sensitivity: 0.001,
                           threshold: 0.05)
        , ControllerAxes.LeftRoll:
            ControllerAxisSettings(motion: OpenSpaceMotions.PanY,
                           invert: true,
                           sensitivity: 0.1,
                           threshold: 0.05)
        , ControllerAxes.BothYaw:
            ControllerAxisSettings(motion: OpenSpaceMotions.GlobalRollX,
                            invert: true,
                            sensitivity: 0.1,
                            threshold: 0.05)
        , ControllerAxes.BothRoll:
            ControllerAxisSettings(motion: OpenSpaceMotions.OrbitY,
                            invert: true,
                            sensitivity: 0.1,
                            threshold: 0.05)

    ]

}

struct OpenSpacePayload: Codable {

    enum PayloadType: String, Codable {
        case none
        case inputState
        case connect
        case disconnect
        case changeFocus
    }

    var type: PayloadType = .none
    var connect: OpenSpaceConnect? = nil
    var inputState: OpenSpaceInputState? = nil
    var disconnect: OpenSpaceDisconnect? = nil
    var changeFocus: OpenSpaceFocus? = nil

    init(type: PayloadType) {
        self.type = type
    }

    init(inputState: OpenSpaceInputState) {
        type = .inputState
        self.inputState = inputState
    }

    init(focusObject: OpenSpaceFocus) {
        type = .changeFocus
        changeFocus = focusObject
    }

    init(focusString: String) {
        self.init(focusObject: OpenSpaceFocus(focus: focusString))
    }
}


struct OpenSpaceFocus: Codable {
    var focus: String = ""
}

struct OpenSpaceInputState: Codable {

    var values: [String: Double?] = [:]

    init() {

    }
    
    init(values: [String: Double?]) {
        self.values = values
    }

    func isEmpty() -> Bool {
        for (_, value) in values {
            if value != nil && value! != 0.0 {
                return false
            }
        }
        return true
    }

    subscript(index: OpenSpaceMotions) -> Double? {
        get {
            return values[index.rawValue]!
        }
        set (newValue) {
            values[index.rawValue] = newValue
        }
    }

    subscript(index: String) -> Double? {
        get {
            guard let i = OpenSpaceMotions(rawValue: index) else {
                print("Cannot convert \(index) to an OpenSpaceMotion")
                return nil
            }
            return values[i.rawValue]!
        }
        set (newValue) {
            guard let i = OpenSpaceMotions(rawValue: index) else {
                print("Cannot convert \(index) to an OpenSpaceMotion")
                return
            }
            values[i.rawValue] = newValue
        }
    }

    /**
     Merges the values of another OpenSpaceInputState into this instance. Optional value
     overwrite determine whether existing values are kept or updated.

     - Parameters:
        - input: An OpenSpaceInputState to add to this object
        - overwrite: Whether existing keys are overwritten by the input (default: false)
     */
    mutating func merge(_ input: OpenSpaceInputState, overwrite: Bool = false) {
        for (key, value) in input.values {
            if (values[key] != nil && !overwrite) {
                continue
            }
            values[key] = value
        }
    }
}

struct OpenSpaceData: Codable {
    let type: String = "flightcontroller"
    var topic: Int
    var payload: OpenSpacePayload
}

struct OpenSpaceConnect: Codable {
    var focusNodes: [String:String]? = nil
    var allNodes: [String:String]? = nil
}

struct OpenSpaceDisconnect: Codable {
    var success: Bool? = nil
}
