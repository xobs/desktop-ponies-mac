//
//  NBPonyEffect.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBPonyBehavior.h"
#import "NBPony.h"

enum PonyEffectDirections {
    none,
    bottomRight,
    bottom,
    bottomLeft,
    left,
    topLeft,
    top,
    topRight,
    right,
    center,
    anyNotCenter,
    any,
};

@interface NBPonyEffect : NSObject {
    NSString *_name;
    NBPonyBehavior *_behavior;
    NSString *_behaviorName;
    NSImage *_leftImage, *_rightImage;
    double _duration;
    double _delay;
    enum PonyEffectDirections _directionLeft, _directionRight;
    enum PonyEffectDirections _centerLeft, _centerRight;
    BOOL _follows;
    
    NBPony *_pony;
}

+ (NBPonyEffect *)arrayToPonyEffect:(NSArray *)array path:(NSString *)path;
- (id)initWithArray:(NSArray *)array path:(NSString *)path;
- (enum PonyEffectDirections)stringToDirection:(NSString *)str;

// Call this after the pony has been completely loaded in order
// to resolve the "Behavior" value.  If this returns FALSE, then
// the behavior could not be found and this effect should not be used.
- (BOOL)resolveBehavior:(NBPony *)pony;

- (NSString *)name;

@end
