//
//  WebsocketManager.swift
//  FlightController
//
//  Created by Matthew Territo on 7/13/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import Starscream

final class WebsocketManager {

    static let shared  = WebsocketManager()
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    var delegate: WebSocketDelegate?

    var socket: WebSocket?

    var isConnected: Bool {
        guard let socket: WebSocket = self.socket else {
            return false
        }
        return socket.isConnected
    }

    private init() {
    }
    
    func addSocket(host: String = "localhost", port: Int = 8001) {
        guard let url = URL(string: "ws://\(host):\(port)") else {
                return
        }
        let socket = WebSocket(url: url)
        socket.delegate = delegate
        self.socket = socket
    }
    
    func connect() {
        guard let socket = self.socket else { return }
        socket.connect()
    }

    func disconnect() {
        guard let socket = self.socket else { return }
        socket.disconnect()
    }

    func write(data: OpenSpaceData) {
        guard let socket = self.socket, socket.isConnected else {
            return
        }

        guard let data = try? WebsocketManager.encoder.encode(data) else {
            return
        }

        guard let packet = String(data: data, encoding: .utf8) else {
            return
        }

        //print("\(OpenSpaceManager.shared.lastInteractionTime?.timeIntervalSinceNow): \(packet)")
        socket.write(string: packet)
    }
}
