//
//  NetworkManager.swift
//  FlightController
//
//  Created by Matthew Territo on 7/26/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

protocol NetworkManager {
    var networkManager: WebsocketManager? { get set }

    func networkManager(_ manager: WebsocketManager?)
}
