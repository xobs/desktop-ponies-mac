//
//  NBPonyInstance.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBPony.h"

@interface NBPonyInstance : NSObject {
    NBPony *_pony;
    NBPonyBehavior *_behavior;
    id _delegate;
    NSTimer *_newBehaviorTimeout;
}

- (NBPonyInstance *)initWithPony:(NBPony *)pony;
- (NBPonyBehavior *)startRandomBehavior;
- (NBPonyBehavior *)startBehavior:(NBPonyBehavior *)behavior;
- (NBPonyBehavior *)behavior;

- (NBPony *)pony;
- (void)setDelegate:(id)delegate;

- (void)didChangeBehavior;

@end
