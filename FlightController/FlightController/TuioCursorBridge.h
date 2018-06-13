//
//  TuioCursorBridge.h
//  FlightController
//
//  Created by Matthew Territo on 6/12/18.
//  Copyright © 2018 OpenSpace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TuioCursor: NSObject {
    @private
    struct TuioCursorWrapper * obj_;
}
- (struct TuioCursorWrapper *)wrapper;
@end