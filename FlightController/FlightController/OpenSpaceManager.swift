//
//  OpenSpaceManager.swift
//  FlightController
//
//  Created by Matthew Territo on 8/6/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import Foundation

protocol OpenSpaceManager {
    /// A dictionary of the focus nodes and their names
    var focusNodes: [String: String?]? { get set }

    /// A list of the focus nodes' names
    var focusNodeNames: [String]? { get }

    /// A dictionary of all nodes and their names
    var allNodes: [String: String?]? { get set }

    /// A list of all nodes' names
    var allNodeNames: [String]? { get }

    /// The last time the view was intereacted with
    var lastInteractionTime: Date? { get set }

    /**
     Sets focusNodes with a dictionary
     - Parameter nodes: [String: String?] 
     */
    func focusNodes(_ nodes: [String: String?]?)

    /**
     Sets all nodes with a dictionary
     */
    func allNodes(_ nodes: [String: String?]?)

    /**
     Sets last interaction time
     */
    func lastInteractionTime(_ date: Date?);
}
