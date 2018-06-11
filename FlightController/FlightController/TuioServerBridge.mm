//
//  TUIOBridge.mm
//  FlightController
//
//  Created by Matthew Territo on 6/8/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuioServerBridge.h"
#import "TUIO/TuioServer.h"


@implementation TuioServer

// MARK: Initializers
- (id)init {
    self = [super init];
    if (self) {
        // init variables
        obj_ = new TUIO::TuioServer();
    }
    return self;
}

- (id)initWithHost:(const NSString *) host port:(int)port {
    self = [super init];
    if (self) {
        // init variables
        obj_ = new TUIO::TuioServer([host UTF8String], port);
    }
    return self;
}

- (void)initialize:(NSString *)host port:(int)port { }

- (void)setSourceName:(NSString *)name host:(NSString *)host {
    obj_->setSourceName([name UTF8String], [host UTF8String]);
}

// MARK: Interaction Handlers
- (void)initFrame:(TuioTime *)time {
    obj_->initFrame(*((__bridge TUIO::TuioTime *) time));
}

- (void)addTuioCursor:(float)x y:(float)y {
    obj_->addTuioCursor(x, y);
}

- (void)addTuioBlob:(float)x y:(float)y a:(float)a w:(float)w h:(float)h f:(float)f {
    obj_->addTuioBlob(x, y, a, w, h, f);
}

- (void)removeTuioCursor:(TuioCursor *)cursor {
    obj_->removeTuioCursor((__bridge TUIO::TuioCursor *) cursor);
}

- (void)removeTuioBlob:(TuioBlob *)blob {
    obj_->removeTuioBlob((__bridge TUIO::TuioBlob *) blob);
}

- (void)updateTuioCursor:(TuioCursor *)cursor x:(float)x y:(float)y {
    obj_->updateTuioCursor((__bridge TUIO::TuioCursor *) cursor, x, y);
}

- (void)updateTuioBlob:(TuioBlob *)blob x:(float)x y:(float)y a:(float)a w:(float)w h:(float)h f:(float)f {
    obj_->updateTuioBlob((__bridge TUIO::TuioBlob *) blob, x, y, a, w, h, f);
}

- (void)stopUntouchedMovingCursors {
    obj_->stopUntouchedMovingCursors();
}

- (void)stopUntouchedMovingBlobs {
    obj_->stopUntouchedMovingBlobs();
}

- (void)commitFrame {
    obj_->commitFrame();
}

// MARK: Set Attributes
- (void)enableObjectProfile:(BOOL)flag {
    obj_->enableObjectProfile(flag);
}

- (void)enableBlobProfile:(BOOL)flag {
    obj_->enableBlobProfile(flag);
}

// MARK: Members
TUIO::TuioServer *obj_;

@end
