//
//  NetworkManager.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

final class NetworkManager {

    static let shared = NetworkManager()

    /// A WebsocketManager? for handing the connection
    var manager: WebsocketManager?

    /// Whether there is a live connection
    var isConnected: Bool {
        guard let manager = self.manager else {
            return false
        }
        return manager.isConnected
    }

    private init() { }

    /**
     Set self.networkManager

     - Parameter manager: A WebsocketManager?
     */
    func networkManager(_ manager: WebsocketManager?) {
        self.manager = manager
    }

    func write(data: OpenSpaceData) {

        guard let manager = self.manager, isConnected else {
            return
        }

        manager.write(data: data)
    }

    func connect() {
        guard let manager = self.manager else {
            return
        }
        manager.connect()
    }

    func disconnect() {
        guard let manager = self.manager, isConnected else {
            return
        }
        manager.disconnect()
    }

    func addSocket(host: String = "localhost", port: Int = 8001) {
        guard let manager = self.manager else {
            return
        }

        manager.addSocket(host: host, port: port)
    }

}
