//
//  JoystickViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 7/24/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

class JoystickViewController: UIViewController, NetworkManager {
    // MARK: NetworkManager protocol
    var networkManager: WebsocketManager?

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

        guard let stickView: JoystickView = self.view as? JoystickView else { return }
        stickView.networkManager = networkManager
        stickView.resetJoysticks()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? JoystickSKViewController {
            destination.networkManager = networkManager
        }
    }

}
