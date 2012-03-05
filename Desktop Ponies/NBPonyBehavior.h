//
//  NBPonyBehavior.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBGraphicsSequence.h"

#define MOVEMENT_NONE 0
#define MOVEMENT_HORIZ 1
#define MOVEMENT_VERT 2
#define MOVEMENT_DIAG 4
#define MOVEMENT_MOUSEOVER 8
#define MOVEMENT_SLEEP 16
#define MOVEMENT_DRAGGING 32
#define MOVEMENT_HORIZ_VERT (MOVEMENT_HORIZ | MOVEMENT_VERT)
#define MOVEMENT_ALL (MOVEMENT_HORIZ | MOVEMENT_VERT | MOVEMENT_DIAG)
#define MOVEMENT_VERT_DIAG (MOVEMENT_VERT | MOVEMENT_DIAG)
#define MOVEMENT_HORIZ_DIAG (MOVEMENT_HORIZ | MOVEMENT_DIAG)

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
    
    NSString *_leftImagePath, *_rightImagePath;
    NBGraphicsSequence *_leftImage, *_rightImage;
}

+ (NBPonyBehavior *)arrayToPonyBehavior:(NSArray *)array path:(NSString *)path;
- (id)initWithArray:(NSArray *)array path:(NSString *)path;

- (NSString *)name;
- (NSString *)leftImagePath;
- (NSString *)rightImagePath;
- (NBGraphicsSequence *)leftImage;
- (NBGraphicsSequence *)rightImage;
- (NSPoint)leftImageCenter;
- (NSPoint)rightImageCenter;
- (NSString *)linkedBehavior;
- (NSPoint)offset;

- (double)probability;
- (double)speed;
- (double)randomTimeout;
- (BOOL)shouldSkip;

- (int)movementFlags;

@end
