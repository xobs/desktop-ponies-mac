//
//  NBPonyBehavior.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBPonyBehavior.h"

enum field_names {
    ignored = 0,
    name = 1,
    probability = 2,
    max_duration = 3,
    min_duration = 4,
    speed = 5, // Specified in pixels per tick of the timer
    right_image_path = 6,
    left_image_path = 7,
    movement_type = 8,
    linked_behavior = 9,
    speaking_start = 10,
    speaking_end = 11,
    skip = 12, // Should we skip this behavior when considering ones to randomly choose (part of an interaction/chain?)
    xcoord = 13, // Used when following/moving to a point on the screen.
    ycoord = 14,
    object_to_follow = 15,
    auto_select_images = 16,
    follow_stopped_behavior = 17,
    follow_moving_behavior = 18,
    right_image_center = 19,
    left_image_center = 20,
};

@implementation NBPonyBehavior

+ (NBPonyBehavior *)arrayToPonyBehavior:(NSArray *)array path:(NSString *)path
{
    return [[[NBPonyBehavior alloc] initWithArray:array path:path] autorelease];
}

- (id)initWithArray:(NSArray *)array path:(NSString *)path
{
    if (!(self = [super init]))
        return nil;

    _name = [[array objectAtIndex:name] copy];
    
    // Parse "movement" field
    NSString *movement = [[array objectAtIndex:movement_type] lowercaseString];
    if ([movement isEqualToString:@"none"])
        _movementType = 0;
    else if ([movement isEqualToString:@"horizontal_only"])
        _movementType = 1;
    else if ([movement isEqualToString:@"vertical_only"])
        _movementType = 2;
    else if ([movement isEqualToString:@"horizontal_vertical"])
        _movementType = 3;
    else if ([movement isEqualToString:@"diagonal_only"])
        _movementType = 4;
    else if ([movement isEqualToString:@"diagonal_horizontal"])
        _movementType = 5;
    else if ([movement isEqualToString:@"diagonal_vertical"])
        _movementType = 6;
    else if ([movement isEqualToString:@"all"])
        _movementType = 7;
    else if ([movement isEqualToString:@"mouseover"])
        _movementType = 8;
    else if ([movement isEqualToString:@"sleep"])
        _movementType = 16;
    else if ([movement isEqualToString:@"dragged"])
        _movementType = 32;
    else {
        NSLog(@"Unrecognized movement \"%@\", assuming \"none\"", movement);
        _movementType = 0;
    }

    if ([array count] > linked_behavior && [[array objectAtIndex:linked_behavior] isEqualToString:@""])
        _linkedBehavior = [[array objectAtIndex:linked_behavior] copy];
    else
        _linkedBehavior = nil;
    
    if ([array count] > speaking_start)
        _speakingStart = [[array objectAtIndex:speaking_start] intValue];
    else
        _speakingStart = 0;
    
    if ([array count] > speaking_end)
        _speakingEnd = [[array objectAtIndex:speaking_end] intValue];
    else
        _speakingEnd = 0;
    
    if ([array count] > skip)
        _skip = [[array objectAtIndex:skip] boolValue];
    else
        _skip = false;
    
    if ([array count] > ycoord)
        _position = NSMakePoint([[array objectAtIndex:xcoord] floatValue], 
                                [[array objectAtIndex:ycoord] floatValue]);
    else
        _position = NSMakePoint(-1, -1);
    
    if ([array count] > object_to_follow)
        _objectToFollow = [[array objectAtIndex:object_to_follow] copy];
    else
        _objectToFollow = nil;
    
    if ([array count] > auto_select_images)
        _autoSelectImages = [[array objectAtIndex:auto_select_images] boolValue];
    else
        _autoSelectImages = true;
    
    if ([array count] > follow_stopped_behavior && ![[array objectAtIndex:follow_stopped_behavior] isEqualToString:@""])
        _followStoppedBehavior = [[array objectAtIndex:follow_stopped_behavior] copy];
    else
        _followStoppedBehavior = nil;
    
    if ([array count] > follow_moving_behavior && [[array objectAtIndex:follow_moving_behavior] isEqualToString:@""])
        _followMovingBehavior = [[array objectAtIndex:follow_moving_behavior] copy];
    else
        _followMovingBehavior = nil;
    
    if ([array count] > left_image_center) {
        NSString *coords = [array objectAtIndex:left_image_center];
        if (coords) {
            NSArray *parts = [coords componentsSeparatedByString:@","];
            if (parts && [parts count] == 2) {
                _leftImageCenter = NSMakePoint([[parts objectAtIndex:0] floatValue],
                                               [[parts objectAtIndex:1] floatValue]);
            }
            else
                _leftImageCenter = NSMakePoint(-1, -1);
        }
        else
            _leftImageCenter = NSMakePoint(-1, -1);
    }
    else
        _leftImageCenter = NSMakePoint(-1, -1);
    
    if ([array count] > right_image_center) {
        NSString *coords = [array objectAtIndex:right_image_center];
        if (coords) {
            NSArray *parts = [coords componentsSeparatedByString:@","];
            if (parts && [parts count] == 2) {
                _rightImageCenter = NSMakePoint([[parts objectAtIndex:0] floatValue],
                                                [[parts objectAtIndex:1] floatValue]);
            }
            else
                _rightImageCenter = NSMakePoint(-1, -1);
        }
        else
            _rightImageCenter = NSMakePoint(-1, -1);
    }
    else
        _rightImageCenter = NSMakePoint(-1, -1);
    
    
    if ([array count] > left_image_path)
        _leftImage = [[NSImage alloc] initByReferencingFile:[path stringByAppendingPathComponent:[array objectAtIndex:left_image_path]]];
    else
        _leftImage = nil;

    
    if ([array count] > right_image_path)
        _rightImage = [[NSImage alloc] initByReferencingFile:[path stringByAppendingPathComponent:[array objectAtIndex:right_image_path]]];
    else
        _rightImage = nil;
    
    if ([array count] > max_duration)
        _maxDuration = [[array objectAtIndex:max_duration] intValue];
    else
        _maxDuration = 0;
    
    if ([array count] > min_duration)
        _minDuration = [[array objectAtIndex:min_duration] intValue];
    else
        _minDuration = 0;
    
    if ([array count] > speed)
        _speed = [[array objectAtIndex:speed] doubleValue];
    else
        _speed = 0;
    
    if ([array count] > probability)
        _probability = [[array objectAtIndex:probability] doubleValue];
    else
        _probability = 0;
    
    
    return self;
}

- (NSString *)name;
{
    return _name;
}

- (NSImage *)leftImage
{
    return _leftImage;
}

- (NSImage *)rightImage
{
    return _rightImage;
}

@end
