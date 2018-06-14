//
//  TuioGestureRecognizer.swift
//  FlightController
//
//  Created by Matthew Territo on 6/13/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TuioGestureRecognizer: UIGestureRecognizer {

    lazy var tuio: TuioSender = TuioSender.shared

//    lazy var tuio: TuioSender = TuioSender(host: "192.168.84.185", port: 3333, tcp: 0, ip: "192.168.84.185", blobs: false)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        let t = touches.first
        let loc = t?.location(in: nil)
        tuio.touchPressed(touchId: 1, x: loc!.x, y: loc!.y, w: 0, h: 0, a: 0)
        tuio.update()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let t = touches.first
        let loc = t?.location(in: nil)
        tuio.touchDragged(touchId: 1, x: loc!.x, y: loc!.y, w: 0, h: 0, a: 0)
        print("Taaaaap it in \(loc!.x), \(loc!.y)")
        tuio.update()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        let t = touches.first
        let loc = t?.location(in: nil)
        tuio.touchReleased(touchId: 1, x: loc!.x, y: loc!.y, w: 0, h: 0, a: 0)
        print("Tap tap tapparoo! \(loc!.x), \(loc!.y)")
        tuio.update()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        tuio.update()
    }
}
