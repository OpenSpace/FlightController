//
//  TuioSender.swift
//  FlightController
//
//  Created by Matthew Territo on 6/12/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

import CoreGraphics

struct TuioCursorInfo {

    var obj: TuioCursor!

    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var w: CGFloat = 0.0
    var h: CGFloat = 0.0
    var a: CGFloat = 0.0
    
    var isAlive : Bool = false  // is it alive this frame
    var wasAlive: Bool = false  // was it alive this frame
    var moved   : Bool = false  // did it move this frame
    
    mutating func setMeasurements(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, a: CGFloat) {
        (self.x, self.y, self.w, self.h, self.a) = (x, y, w, h, a)
    }
    
    func getMeasurements() -> (CGFloat, CGFloat, CGFloat, CGFloat, CGFloat) {
        return (x, y, w, h, a)
    }
    
    func isNew() -> Bool {
        return (isAlive && !wasAlive) || obj == nil
    }
    
    func isMoving() -> Bool {
        return isAlive && wasAlive && moved
    }
    
    func isReleased() -> Bool {
        return wasAlive && !isAlive
    }

    mutating func reset() {
        obj = nil
        (isAlive, wasAlive, moved) = (false, false, false)
        setMeasurements(x: 0, y: 0, w: 0, h: 0, a: 0)
    }
}

final class TuioSender {
    static let defaultHost = "127.0.0.1"
    static let shared = TuioSender(host: defaultHost, port: 3333, tcp: 0, ip: defaultHost, blobs: false)

    static var MAX_TOUCHES = 10
    
    var tuioServer: TuioServer!
    var cursors = Array<TuioCursorInfo>(repeating: TuioCursorInfo(), count: MAX_TOUCHES)
    
    private init() {
        tuioServer = TuioServer()
    }
    
    private init(host: String, port: Int, tcp: Int, ip: String, blobs: Bool) {
        if (setup(host: host, port: port, tcp: tcp, ip: ip, blobs: blobs)) {
            print("TuioSender initialized")
        }
    }
    
    func setup(host: String, port: Int, tcp: Int, ip: String, blobs: Bool) -> Bool {
        tuioServer = TuioServer(host: host, port: port)
        tuioServer.enableObjectProfile(false)
        tuioServer.enableBlobProfile(blobs)
        tuioServer.setSourceName("OpenSpace Flight Controller", host: host)
        return true
    }
    
    func update() {
        if (tuioServer == nil) { return }
        tuioServer.initFrame()
        
        // TODO: Handle Cursors
        //for i in 0...TuioSender.MAX_TOUCHES - 1 {
        for i in 0...1 {
            updateCursor(cursor: &cursors[i])
        }
        
        tuioServer.stopUntouchedMovingCursors();
        tuioServer.commitFrame();
    }
    
    private func updateCursor(cursor: inout TuioCursorInfo) {
        let (x, y, _, _, _) = cursor.getMeasurements()
        if (cursor.isNew()) {
            // Add a new cursor
            cursor.obj = tuioServer.tuioCursorAdd(x, y: y)
        } else if (cursor.isReleased()) {
            // Remove the cursor
            tuioServer.tuioCursorDelete(cursor.obj);
            cursor.reset()
        } else if (cursor.isMoving()) {
            // Update the values
            cursor.moved = false
            tuioServer.tuioCursorUpdate(cursor.obj, x: x, y: y)
        }
        cursor.wasAlive = cursor.isAlive
    }
    
    func close() {
        tuioServer = nil
    }
    
    func touchPressed(touchId: Int, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, a: CGFloat) {
        cursors[touchId].setMeasurements(x: x, y: y, w: w, h: h, a: a)
        cursors[touchId].isAlive = true
    }
    
    func touchDragged(touchId: Int, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, a: CGFloat) {
        cursors[touchId].setMeasurements(x: x, y: y, w: w, h: h, a: a)
        cursors[touchId].isAlive = true
        cursors[touchId].moved = true
    }
    
    func touchReleased(touchId: Int, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, a: CGFloat) {
        cursors[touchId].setMeasurements(x: x, y: y, w: w, h: h, a: a)
        cursors[touchId].isAlive = false
    }
} // TuioSender
