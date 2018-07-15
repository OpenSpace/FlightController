//
//  WebsocketSender.swift
//  FlightController
//
//  Created by Matthew Territo on 7/13/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import Foundation
import Starscream

final class WebsocketSender {

    let socket = WebSocket(url: URL(string: "ws://localhost:8001")!)

    private init() {
        socket.connect()
    }

}
