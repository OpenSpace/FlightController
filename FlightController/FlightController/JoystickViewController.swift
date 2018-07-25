//
//  JoystickViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 7/24/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

class JoystickViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var leftStick: UIImageView!
    @IBOutlet weak var rightStick: UIImageView!

    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard let v: JoystickView = self.view as? JoystickView else { return }
        v.resetJoysticks()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}
