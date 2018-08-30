//
//  OpenSpaceManager.swift
//  FlightController
//
//  Created by Matthew Territo on 8/6/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import Foundation
import UIKit

final class OpenSpaceManager {

    static let shared = OpenSpaceManager()

    enum ScreenOrientation: Int {
        case LandscapeLeft = 1
        case LandscapeRight = -1
        case Portrait = 2

        var d: Double {
            return Double(rawValue)
        }

        var i: Int {
            return rawValue
        }
    }

    ///
    var orientation: ScreenOrientation = .LandscapeLeft

    /// A dictionary of the focus nodes and their names
    var focusNodes: [String: String?]?

    /// A list of the focus nodes' names
    var focusNodeNames: [String]?

    /// A dictionary of all nodes and their names
    var allNodes: [String: String?]?

    /// A list of all nodes' names
    var allNodeNames: [String]?

    /// Threshold for force touch
    var forceThreshold: Double = 4.0

    /// The last time the view was intereacted with
    var lastInteractionTime: Date?

    /// Timeout before controller begins to doSomethingInteresting()
    var interestingCallback: Double = 3.0

    /// Friction Enabled
    var frictionEnabled: Bool = true

    /// If waiting for friction to return from OpenSpace
    var waitingForFriction: Bool = false

    /// Autopilot engaged
    var autopilotEngaged: Bool = false

    /// If waiting for autopilot to return from OpenSpace
    var waitingForAutopilot: Bool = false

    let defaultMotion: OpenSpaceInputState = OpenSpaceInputState(
        values: [OpenSpaceMotions.OrbitX.rawValue: 0.01])

    /// Input state that defines what is done in doSomethingInteresting()
    var somethingInteresting: OpenSpaceInputState

    /// Whether or not to engage "something interesting" mode
    var shouldDoSomethingInteresting: Bool {
        guard let lastMovement = lastInteractionTime, NetworkManager.shared.isConnected else {
            return false
        }

        return lastMovement.timeIntervalSinceNow.isLess(than: -interestingCallback)
    }

    var isPortrait: Bool {
        return OpenSpaceManager.shared.orientation == .Portrait
    }

    var isDeepPressed: Bool = false

    var shouldAutoRotate: Bool {
        return !isDeepPressed
    }

    private init() {
        somethingInteresting = defaultMotion
    }

    /**
     Sets focusNodes with a dictionary
     - Parameter nodes: [String: String?] 
     */
    func focusNodes(_ nodes: [String: String?]?) {
        focusNodes = nodes
        focusNodeNames = focusNodes?.keys.sorted {
            return $0 < $1
            } ?? []
    }
    /**
     Sets all nodes with a dictionary
     */
    func allNodes(_ nodes: [String: String?]?) {
        allNodes = nodes
        allNodeNames = allNodes?.keys.sorted {
            return $0 < $1
            } ?? []
    }

    /**
     Sets last interaction time
     */
    func lastInteractionTime(_ date: Date?)  {
        lastInteractionTime = date
    }

    /**
     Resets to defaults
     */
    func reset() {
        focusNodes = nil
        focusNodeNames = nil
        allNodes = nil
        allNodeNames = nil
        forceThreshold = 4.0
        lastInteractionTime = nil
        interestingCallback = 3.0
        autopilotEngaged = false
        waitingForAutopilot = false
        somethingInteresting = defaultMotion
    }

    func updateOrientation() {
        switch (UIDevice.current.orientation) {
        case .landscapeLeft:
            orientation = .LandscapeLeft
            break
        case .landscapeRight:
            orientation = .LandscapeRight
            break
        case .portrait:
            orientation = .Portrait
            break
        default:
            orientation = .LandscapeLeft
            break
        }
    }
}
