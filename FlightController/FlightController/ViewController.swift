//
//  ViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 5/23/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import CoreMotion
import simd

class ViewController: ConfiguredViewController {
    // MARK: Outlets
    @IBOutlet weak var socketHost: UITextField!

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction
    func connectSocket() {
        let host = (socketHost.text ?? "").isEmpty ? socketHost.placeholder : socketHost.text

        networkManager?.addSocket(host: host!)
        networkManager?.connect()

        networkManager?.write(data: OpenSpaceNavigationSocket(topic:1,
            payload: OpenSpaceNavigationPayload(type: "connect")))

    }

    @IBAction
    func disconnectSocket() {
        networkManager?.write(data: OpenSpaceNavigationSocket(topic:1,
            payload: OpenSpaceNavigationPayload(type: "disconnect")))
        networkManager?.disconnect()
    }
}
