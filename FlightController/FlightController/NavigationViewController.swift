//
//  NavigationViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import CoreMotion

class NavigationViewController: UINavigationController, NetworkManager, MotionManager {
    // MARK: NetworkManager protocol
    var networkManager: WebsocketManager?

    func networkManager(_ manager: WebsocketManager?) {
        networkManager = manager
    }

    // MARK: MotionManager protocol
    var motionManager: CMMotionManager?
    var referenceAttitude: CMAttitude!

    func motionManager(_ manager: CMMotionManager?) {
        motionManager = manager
    }

    func referenceAttitude(_ reference: CMAttitude?) {
        referenceAttitude = reference
    }

    // MARK: UIViewController overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewController = topViewController as? MotionManager {
            viewController.motionManager(motionManager)

        }
        if let viewController = topViewController as? NetworkManager {
            viewController.networkManager(networkManager)
        }
    }
}
