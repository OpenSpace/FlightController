//
//  TuioBlobBridge.mm
//  FlightController
//
//  Created by Matthew Territo on 6/12/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuioBlobBridge.h"
#import "TuioBlobWrapper.hpp"

@implementation TuioBlob

// MARK: Initializers
- (id)init {
    self = [super init];
    if (self) {
        // init variables
        obj_ = new TuioBlobWrapper();
    }
    return self;
}

- (struct TuioBlobWrapper *)wrapper {
    return obj_;
}

@end
