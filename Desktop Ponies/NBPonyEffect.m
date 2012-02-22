//
//  NBPonyEffect.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBPonyEffect.h"

@implementation NBPonyEffect 

+ (NBPonyEffect *)arrayToPonyEffect:(NSArray *)array path:(NSString *)path
{
    return [[[NBPonyEffect alloc] initWithArray:array path:path] autorelease];
}

- (id)initWithArray:(NSArray *)array path:(NSString *)path
{
    if (!(self = [super init]))
        return nil;
    
    if ([array count] < 6) {
        NSLog(@"Too few components for effect: %@", array);
        [self release];
        return nil;
    }
    
    _name = [[array objectAtIndex:1] copy];
    _behaviorName = [[array objectAtIndex:2] copy];
    _rightImage = [[NSImage alloc] initByReferencingFile:[path stringByAppendingPathComponent:[array objectAtIndex:3]]];
    _leftImage = [[NSImage alloc] initByReferencingFile:[path stringByAppendingPathComponent:[array objectAtIndex:4]]];
    _duration = [[array objectAtIndex:5] doubleValue];
    _delay = [[array objectAtIndex:6] doubleValue];
    
    _directionLeft = _directionRight = _centerLeft = _centerRight = 0;
    _follows = false;
    
    if ([array count] > 10) {
        _directionRight = [[array objectAtIndex:7] intValue];
        _centerRight = [[array objectAtIndex:8] intValue];
        _directionLeft = [[array objectAtIndex:9] intValue];
        _centerLeft = [[array objectAtIndex:10] intValue];
    }
    
    if ([array count] > 11) {
        _follows = [[array objectAtIndex:11] boolValue];
    }

    return self;
}

- (NSString *)name
{
    return _name;
}

- (BOOL)resolveBehavior:(NBPony *)pony
{
    _pony = pony;
    _behavior = [[pony behaviors] objectForKey:_behaviorName];
    
    if (!_behavior)
        return false;
    
    return true;
}


@end
