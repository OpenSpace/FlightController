//
//  WebsocketManager.swift
//  FlightController
//
//  Created by Matthew Territo on 7/13/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import Starscream

final class WebsocketManager {


    static let shared = WebsocketManager()

    static let encoder = JSONEncoder()

    var socket: WebSocket?

    init() {
    }
    
    func addSocket(host: String = "localhost", port: Int = 8001) {
        socket = WebSocket(url: URL(string: "ws://\(host):\(port)")!)
    }
    
    func connect() {
        socket?.connect()
    }

    func disconnect() {
        socket?.disconnect()
    }

    func write(data: NavigationSocket) {
        guard let data = try? WebsocketManager.encoder.encode(data) else {
            return
        }
        socket?.write(string: String(data: data, encoding: .utf8)!)
    }

}
