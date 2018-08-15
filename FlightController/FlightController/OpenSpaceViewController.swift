//
//  OpenSpaceViewController.swift
//  FlightController
//
//  Created by Matthew Territo on 8/1/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import Starscream

class OpenSpaceViewController: UIViewController {

    // MARK: UIViewController overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let networkManager = NetworkManager.shared.manager ?? WebsocketManager.shared

        networkManager.delegate = self
        NetworkManager.shared.manager = networkManager

        if OpenSpaceManager.shared.lastInteractionTime == nil {
            OpenSpaceManager.shared.lastInteractionTime = Date()
        }
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    /**
     Do something interesting. Sends a payload with an input state, based on
     **somethingInteresting**
     */
    func doSomethingInteresting() {
        NetworkManager.shared.write(data: OpenSpaceData(topic: 1, payload: OpenSpacePayload(inputState: OpenSpaceManager.shared.somethingInteresting)))
    }
}

extension OpenSpaceViewController: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocketClient) {
        let payload = OpenSpacePayload(type: .connect)
        let data = OpenSpaceData(topic: 1, payload: payload)
        NetworkManager.shared.write(data: data)

    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Disconnected")
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let json = try? WebsocketManager.decoder.decode(OpenSpaceData.self, from: text.data(using: .utf8)!) else {
            print("Could not decode message received from OpenSpace: \(text)")
            return
        }

        // Handle the different payload types
        if let connectPayload = json.payload.connect {
            OpenSpaceManager.shared.focusNodes(connectPayload.focusNodes)
            OpenSpaceManager.shared.allNodes(connectPayload.allNodes)
        }

        if let _ = json.payload.disconnect {
            NetworkManager.shared.disconnect()
        }
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Data received")
    }
}

