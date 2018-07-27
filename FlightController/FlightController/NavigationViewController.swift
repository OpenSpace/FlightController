//
//  NavigationViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import CoreMotion

class NavigationViewController: UINavigationController, NetworkManager,  MotionManager {
    // MARK: NetworkManager protocol
    var networkManager: WebsocketManager?

    // MARK: MotionManager protocol
    var motionManager: CMMotionManager?
    var referenceAttitude: CMAttitude!

    // MARK: UIViewController overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewController = topViewController as? ViewController {
            viewController.motionManager = motionManager
            viewController.networkManager = networkManager
        }
    }
}
