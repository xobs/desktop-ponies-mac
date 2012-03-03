//
//  NBGraphicsSequence.h
//  Desktop Ponies
//
//  Created by Sean Cross on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

struct image;
@interface NBGraphicsSequence : NSObject {
    unsigned int    totalFrames;
    NSSize          size;
    struct image   *data;
}

- (id)initWithPath:(NSString *)path;

- (int)width;
- (int)height;
- (NSSize)size;

- (int)totalFrames;

/* Get the current frame's image data (as 32-bit RGBA) */
- (void *)dataForFrame:(int)frame;
- (int)delayForFrame:(int)frame;
- (unsigned int)textureIdForFrame:(int)frame;
- (void)setTextureId:(unsigned int)tex forFrame:(int)frame;

@end
