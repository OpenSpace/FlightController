//
//  TuiServerBridge.h
//  FlightController
//
//  Created by Matthew Territo on 6/8/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//
#import <Foundation/Foundation.h>

// MARK: Forward declarations
@class TuioCursor;
@class TuioBlob;
@class TuioTime;

@interface TuioServer: NSObject
// MARK: Initializaters
- (id)initWithHost:(NSString *)host port:(int)port;
- (void)initialize:(NSString *)host port:(int)port;
- (void)setSourceName:(NSString *)name host:(NSString *)host;

// MARK: Interaction Handlers
- (void)initFrame:(TuioTime *)time;

- (TuioCursor *)addTuioCursor:(float)x y:(float)y;
- (TuioBlob *)addTuioBlob:(float)x y:(float)y a:(float)a w:(float)w h:(float)h f:(float)f;

- (void)removeTuioCursor:(TuioCursor *)cursor;
- (void)removeTuioBlob:(TuioBlob *)blob;

- (void)updateTuioCursor:(TuioCursor *)cursor x:(float)x y:(float)y;
- (void)updateTuioBlob:(TuioBlob *)blob x:(float)x y:(float)y a:(float)a w:(float)w h:(float)h f:(float)f;

- (void)stopUntouchedMovingCursors;
- (void)stopUntouchedMovingBlobs;

- (void)commitFrame;

// MARK: Setters
- (void)enableObjectProfile:(BOOL) flag;
- (void)enableBlobProfile:(BOOL) flag;


@end

