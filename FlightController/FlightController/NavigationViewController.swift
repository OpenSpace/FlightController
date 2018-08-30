//
//  NavigationViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override var shouldAutorotate: Bool {
        guard let currentView = topViewController as? JoystickViewController else {
            return true
        }
        return currentView.shouldAutorotate
    }
}

