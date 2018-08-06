//
//  NetworkManager.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

protocol NetworkManager {
    /// A WebsocketManager? for handing the connection
    var networkManager: WebsocketManager? { get set }

    /**
     Set self.networkManager

     - Parameter manager: A WebsocketManager?
     */
    func networkManager(_ manager: WebsocketManager?)
}
