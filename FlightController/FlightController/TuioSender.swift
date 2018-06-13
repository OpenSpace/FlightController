//
//  TuioSender.swift
//  FlightController
//
//  Created by Matthew Territo on 6/12/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

struct TuioCursorInfo {
    var x: Float = 0.0
    var y: Float = 0.0
    var w: Float = 0.0
    var h: Float = 0.0
    var a: Float = 0.0
    
    var isAlive : Bool = false  // is it alive this frame
    var wasAlive: Bool = false  // was it alive this frame
    var moved   : Bool = false  // did it move this frame
    
    mutating func setMeasurements(x: Float, y: Float, w: Float, h: Float, a: Float) {
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.a = a
    }
    
    func getMeasurements() -> (Float, Float, Float, Float, Float) {
        return (x, y, w, h, a)
    }
    
    func isNew() -> Bool {
        return isAlive && !wasAlive
    }
    
    func isMoving() -> Bool {
        return isAlive && wasAlive && moved
    }
    
    func isReleased() -> Bool {
        return wasAlive && !isAlive
    }
}

class TuioSender {
    
    static var MAX_TOUCHES = 10
    
    var tuioServer: TuioServer!
    var cursors = Array<TuioCursorInfo>(repeating: TuioCursorInfo(), count: MAX_TOUCHES)
    
    init() {
        tuioServer = TuioServer()
    }
    
    init(host: String, port: Int, tcp: Int, ip: String, blobs: Bool) {
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
        for i in 1...TuioSender.MAX_TOUCHES {
            updateCursor(cursor: cursors[i])
        }
        
        tuioServer.stopUntouchedMovingCursors();
        // if (do_blobs) tuioServer.stopUntouchedMovingBlobs();
        tuioServer.commitFrame();
    }
    
    private func updateCursor(cursor: TuioCursorInfo) {
        var (x, y, w, h, a) = cursor.getMeasurements()
        if (cursor.isNew()) {
            // Add a new cursor
            tuioServer.tuioCursorAdd(x, y: y)
        } else if (cursor.isReleased()) {
            // Remove the cursor
            tuioServer.tuioCursorDelete(nil);
        } else if (cursor.isMoving()) {
            // Update the values
            tuioServer.tuioCursorUpdate(nil, x: x, y: y)
        }
    }
    
    func close() {
        tuioServer = nil
    }
    
    func touchPressed(touchId: Int, x: Float, y: Float, w: Float, h: Float, a: Float) {
        cursors[touchId].setMeasurements(x: x, y: y, w: w, h: h, a: a)
        cursors[touchId].isAlive = true
    }
    
    func touchDragged(touchId: Int, x: Float, y: Float, w: Float, h: Float, a: Float) {
        cursors[touchId].setMeasurements(x: x, y: y, w: w, h: h, a: a)
        cursors[touchId].isAlive = true
        cursors[touchId].wasAlive = true
    }
    
    func touchReleased(touchId: Int, x: Float, y: Float, w: Float, h: Float, a: Float) {
        cursors[touchId].setMeasurements(x: x, y: y, w: w, h: h, a: a)
        cursors[touchId].isAlive = false
    }
    
} // TuioSender
