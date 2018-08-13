//
//  OpenSpaceManager.swift
//  FlightController
//
//  Created by Matthew Territo on 8/6/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import Foundation

protocol OpenSpaceManager {
    /// A list of the focus nodes
    var focusNodes: [String: String?]? { get set }
    var focusNodeNames: [String]? { get }

    var allNodes: [String: String?]? { get set }
    var allNodeNames: [String]? { get }

    var lastInteractionTime: Date? { get set }

    func focusNodes(_ nodes: [String: String?]?)
    func allNodes(_ nodes: [String: String?]?)
    func lastInteractionTime(_ date: Date?);
}
