//
//  OpenSpaceManager.swift
//  FlightController
//
//  Created by Matthew Territo on 8/6/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import Foundation

final class OpenSpaceManager {

    static let shared = OpenSpaceManager()

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
    var interestingCallback: Double = 5.0

    /// Input state that defines what is done in doSomethingInteresting()
    var somethingInteresting: OpenSpaceInputState = OpenSpaceInputState(
        values: [OpenSpaceMotions.OrbitX.rawValue: 0.0015])

    /// Whether or not to engage "something interesting" mode
    var shouldDoSomethingInteresting: Bool {
        guard let lastMovement = lastInteractionTime, NetworkManager.shared.isConnected else {
            return false
        }

        return lastMovement.timeIntervalSinceNow.isLess(than: -interestingCallback)
    }

    private init() { }

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
}
