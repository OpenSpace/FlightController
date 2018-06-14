//
//  TuioServerBridge.mm
//  FlightController
//
//  Created by Matthew Territo on 6/8/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuioServerBridge.h"
#import "TuioCursorBridge.h"
#import "TuioCursorWrapper.hpp"
#import "TuioBlobBridge.h"
#import "TuioBlobWrapper.hpp"
#import "TUIO/TuioServer.h"
#import "TUIO/TuioCursor.h"
#import "TUIO/TuioTime.h"


@implementation TuioServer {
    // MARK: Members
    TUIO::TuioServer *obj_;
}

// MARK: Initializers
- (id)init {
    self = [super init];
    if (self) {
        // init variables
        obj_ = new TUIO::TuioServer();
    }
    return self;
}

- (id)initWithHost:(const NSString *) host port:(NSInteger)port {
    self = [super init];
    if (self) {
        // init variables
        obj_ = new TUIO::TuioServer([host UTF8String], (int) port);
    }
    return self;
}

- (void)initialize:(NSString *)host port:(NSInteger)port { }

- (void)setSourceName:(NSString *)name host:(NSString *)host {
    obj_->setSourceName([name UTF8String], [host UTF8String]);
}

-(void)dealloc {
    if (obj_) {
        delete obj_;
    }
    obj_ = nil;
}

// MARK: Interaction Handlers
- (void)initFrame {
    obj_->initFrame( TUIO::TuioTime::getSessionTime() );
}

- (void)initFrame:(TuioTime *)time {
    obj_->initFrame( *((__bridge TUIO::TuioTime *) time) );
}

- (TuioCursor *)tuioCursorAdd:(CGFloat)x y:(CGFloat)y {
    TuioCursor * ret = [TuioCursor alloc];
    ret.wrapper->cursor = obj_->addTuioCursor(x, y);
    return ret;
}

- (TuioBlob *)tuioBlobAdd:(CGFloat)x y:(CGFloat)y a:(CGFloat)a w:(CGFloat)w h:(CGFloat)h f:(CGFloat)f {
    TuioBlob * ret = [TuioBlob alloc];
    ret.wrapper->blob = obj_->addTuioBlob(x, y, a, w, h, f);
    return ret;
}

- (void)tuioCursorDelete:(TuioCursor *)cursor {
    obj_->removeTuioCursor(cursor.wrapper->cursor);
}

- (void)tuioBlobDelete:(TuioBlob *)blob {
    obj_->removeTuioBlob(blob.wrapper->blob);
}

- (void)tuioCursorUpdate:(TuioCursor *)cursor x:(CGFloat)x y:(CGFloat)y {
    obj_->updateTuioCursor(cursor.wrapper->cursor, x, y);
}

- (void)tuioBlobUpdate:(TuioBlob *)blob x:(CGFloat)x y:(CGFloat)y a:(CGFloat)a w:(CGFloat)w h:(CGFloat)h f:(CGFloat)f {
    obj_->updateTuioBlob(blob.wrapper->blob, x, y, a, w, h, f);
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

- (void)enablePeriodicMessages {
    [self enablePeriodicMessages:1];
}

- (void)enablePeriodicMessages:(NSInteger)interval {
    obj_->enablePeriodicMessages( (int) interval);
}

- (void)disablePeriodicMessages {
    obj_->disablePeriodicMessages();
}

- (void)testing:(NSObject *)ob {
    printf("%s\n", object_getClassName(ob));
    printf("%s\n", [TuioCursor.description UTF8String]);
    
}
@end
