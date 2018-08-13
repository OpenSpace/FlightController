//
//  WebsocketManager.swift
//  FlightController
//
//  Created by Matthew Territo on 7/13/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import Starscream

final class WebsocketManager {

    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    var delegate: WebSocketDelegate?

    var socket: WebSocket?

    init() {
    }
    
    func addSocket(host: String = "localhost", port: Int = 8001) {
        socket = WebSocket(url: URL(string: "ws://\(host):\(port)")!)
        socket?.delegate = delegate
    }
    
    func connect() {
        socket?.connect()
    }

    func disconnect() {
        socket?.disconnect()
    }

    func write(data: OpenSpaceData) {
        guard let data = try? WebsocketManager.encoder.encode(data) else {
            return
        }
        socket?.write(string: String(data: data, encoding: .utf8)!)
    }
}
