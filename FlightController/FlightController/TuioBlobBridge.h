//
//  TuioBlobBridge.h
//  FlightController
//
//  Created by Matthew Territo on 6/12/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TuioBlob: NSObject {
    @private
   struct TuioBlobWrapper * obj_;
}

- (struct TuioBlobWrapper *)wrapper;
@end
