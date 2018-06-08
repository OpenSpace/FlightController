//
//  TUIOBridge.mm
//  FlightController
//
//  Created by Matthew Territo on 6/8/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIOBridge.h"
#import "TUIO/TuioServer.h"


@implementation TUIOBridge

TUIO::TuioServer *myObject;

- (id)init {
    self = [super init];
    if (self) {
        // init variables
        myObject = new TUIO::TuioServer();
    }
    return self;
}

- (void)testFunction
{
    printf("Update interval: %d\n", myObject->getUpdateInterval());
}

@end
