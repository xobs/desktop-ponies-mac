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
        _directionRight = [self stringToDirection:[array objectAtIndex:7]];
        _centerRight = [self stringToDirection:[array objectAtIndex:8]];
        _directionLeft = [self stringToDirection:[array objectAtIndex:9]];
        _centerLeft = [self stringToDirection:[array objectAtIndex:10]];
    }
    
    if ([array count] > 11) {
        _follows = [[array objectAtIndex:11] boolValue];
    }

    return self;
}

- (enum PonyEffectDirections)stringToDirection:(NSString *)str
{
    str = [[str lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([str isEqualToString:@"center"])
        return center;
    else if ([str isEqualToString:@"left"])
        return left;
    else if ([str isEqualToString:@"bottom_left"])
        return bottomLeft;
    else if ([str isEqualToString:@"bottom"])
        return bottom;
    else if ([str isEqualToString:@"bottom_right"])
        return bottomRight;
    else if ([str isEqualToString:@"right"])
        return right;
    else if ([str isEqualToString:@"top_right"])
        return topRight;
    else if ([str isEqualToString:@"top"])
        return top;
    else if ([str isEqualToString:@"top_left"])
        return topLeft;
    else if ([str isEqualToString:@"any_notcenter"] || [str isEqualToString:@"any-not_center"])
        return anyNotCenter;
    else if ([str isEqualToString:@"any"])
        return any;
    else {
        NSLog(@"Unrecognized direction: %@", str);
        return none;
    }
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
