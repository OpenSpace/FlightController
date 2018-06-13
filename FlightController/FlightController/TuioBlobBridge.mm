//
//  TuioBlobBridge.mm
//  FlightController
//
//  Created by Matthew Territo on 6/12/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuioBlobBridge.h"
#import "TUIO/TuioBlob.h"

@implementation TuioBlob {
    // MARK: Members
    TUIO::TuioBlob * obj_;
}

// MARK: Initializers
- (id)init {
    self = [super init];
    if (self) {
        // init variables
        obj_ = nil;
    }
    return self;
}

@end
