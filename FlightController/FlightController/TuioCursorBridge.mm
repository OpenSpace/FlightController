//
//  TuioCursorBridge.mm
//  FlightController
//
//  Created by Matthew Territo on 6/12/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuioCursorBridge.h"
#import "TuioCursorWrapper.hpp"

@implementation TuioCursor

// MARK: Initializers
- (id)init {
    self = [super init];
    if (self) {
        // init variables
        obj_ = new TuioCursorWrapper();
    }
    return self;
}

- (struct TuioCursorWrapper *)wrapper {
    return obj_;
}

@end
