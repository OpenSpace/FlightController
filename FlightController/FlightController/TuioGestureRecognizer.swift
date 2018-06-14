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
        let x = loc!.x/self.view!.window!.frame.width
        let y = loc!.y/self.view!.window!.frame.height

        tuio.touchPressed(touchId: 1, x: x, y: y, w: 0, h: 0, a: 0)
        print("Just tap it in \(x), \(y)")
        tuio.update()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let t = touches.first

        let loc = t?.location(in: nil)
        let x = loc!.x/self.view!.window!.frame.width
        let y = loc!.y/self.view!.window!.frame.height

        tuio.touchDragged(touchId: 1, x: x, y: y, w: 0, h: 0, a: 0)
        print("Taaaaap it in \(x), \(y)")
        tuio.update()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        let t = touches.first

        let loc = t?.location(in: nil)
        let x = loc!.x/self.view!.window!.frame.width
        let y = loc!.y/self.view!.window!.frame.height

        tuio.touchReleased(touchId: 1, x: x, y: y, w: 0, h: 0, a: 0)
        print("Tap tap tapparoo! \(x), \(y)")
        tuio.update()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        tuio.update()
    }
}
