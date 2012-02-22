//
//  NBPonyBehavior.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBPonyBehavior : NSObject {
    NSString *_name;
    
    double _probability;
    double _speed;

    int _movementType;
    double _maxDuration, _minDuration;
    NSString *_linkedBehavior;
    int _speakingStart, _speakingEnd;
    BOOL _skip;
    NSPoint _position;
    NSString *_objectToFollow;
    BOOL _autoSelectImages;
    NSString *_followStoppedBehavior, *_followMovingBehavior;
    NSPoint _rightImageCenter, _leftImageCenter;
    
    NSImage *_leftImage, *_rightImage;
}

+ (NBPonyBehavior *)arrayToPonyBehavior:(NSArray *)array path:(NSString *)path;
- (id)initWithArray:(NSArray *)array path:(NSString *)path;

- (NSString *)name;
- (NSImage *)leftImage;
- (NSImage *)rightImage;
- (double)probability;
- (double)randomTimeout;
- (BOOL)shouldSkip;

@end
