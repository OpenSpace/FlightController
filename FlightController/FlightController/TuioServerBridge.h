//
//  TuiServerBridge.h
//  FlightController
//
//  Created by Matthew Territo on 6/8/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TuioCursorBridge.h"
#import "TuioBlobBridge.h"
// MARK: Forward declarations


@class TuioTime;

@interface TuioServer: NSObject
// MARK: Initializaters
- (id)initWithHost:(NSString *)host port:(NSInteger)port;
- (void)initialize:(NSString *)host port:(NSInteger)port;
- (void)setSourceName:(NSString *)name host:(NSString *)host;
- (void)dealloc;

// MARK: Interaction Handlers
- (void)initFrame;
- (void)initFrame:(TuioTime *)time;

- (TuioCursor *)tuioCursorAdd:(CGFloat)x y:(CGFloat)y;
- (TuioBlob *)tuioBlobAdd:(CGFloat)x y:(CGFloat)y a:(CGFloat)a w:(CGFloat)w h:(CGFloat)h f:(CGFloat)f;

- (void)tuioCursorDelete:(TuioCursor *)cursor;
- (void)tuioBlobDelete:(TuioBlob *)blob;

- (void)tuioCursorUpdate:(TuioCursor *)cursor x:(CGFloat)x y:(CGFloat)y;
- (void)tuioBlobUpdate:(TuioBlob *)blob x:(CGFloat)x y:(CGFloat)y a:(CGFloat)a w:(CGFloat)w h:(CGFloat)h f:(CGFloat)f;

- (void)stopUntouchedMovingCursors;
- (void)stopUntouchedMovingBlobs;

- (void)commitFrame;

// MARK: Setters
- (void)enableObjectProfile:(BOOL) flag;
- (void)enableBlobProfile:(BOOL) flag;
- (void)enablePeriodicMessages;
- (void)enablePeriodicMessages:(NSInteger) interval;
- (void)disablePeriodicMessages;

- (void)testing:(NSObject *)ob;
@end
