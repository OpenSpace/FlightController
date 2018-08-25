//
//  ConnectionViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 5/23/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit

class ConnectionViewController: OpenSpaceViewController {
    // MARK: Outlets
    @IBOutlet weak var socketHost: UITextField!

    /**
     Connects a socket via the NetworkManager. Uses the sockeHost placeholder text if none
     provided
     */
    @IBAction
    func connectSocket() {

        let host = (socketHost.text ?? "").isEmpty ? socketHost.placeholder! : socketHost.text!

        NetworkManager.shared.addSocket(host: host)
        NetworkManager.shared.connect()
        OpenSpaceManager.shared.reset()
    }

    /**
     Disconnects a socket via the NetworkManager.
     */
    @IBAction
    func disconnectSocket() {
        disableAutopilot()
        NetworkManager.shared.write(data: OpenSpaceData(topic: 1, payload: OpenSpacePayload(type: .disconnect)))
    }
}
