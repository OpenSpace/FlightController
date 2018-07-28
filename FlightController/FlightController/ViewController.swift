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

class ViewController: UIViewController, NetworkManager, MotionManager {
    // MARK: NetworkManager protocol
    var networkManager: WebsocketManager?

    func networkManager(_ manager: WebsocketManager?) {
        networkManager = manager
    }

    // MARK: MotionManager protocol
    var motionManager: CMMotionManager?
    var referenceAttitude: CMAttitude!
    var currentAttitude: CMAttitude?
    static var forceThreshold: CGFloat = 4.0


    func motionManager(_ manager: CMMotionManager?) {
        motionManager = manager
    }

    func referenceAttitude(_ reference: CMAttitude?) {
        referenceAttitude = reference
    }

    func startUpdates() {
        return
    }

    func stopUpdates() {
        return
    }

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? NetworkManager {
            destination.networkManager(networkManager)
        }
        if let destination = segue.destination as? MotionManager {
            destination.motionManager(motionManager)
        }
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
