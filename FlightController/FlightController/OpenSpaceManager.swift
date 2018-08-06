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

    func focusNodes(_ nodes: [String: String?]?)
}
