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
    unsigned int    currentFrame;
    unsigned int    totalFrames;
    unsigned int    millisLeft;
    NSSize          size;
    struct image   *data;
}

- (id)initWithPath:(NSString *)path;

/* Call this once every 10ms */
- (BOOL)tick:(long long)elapsed;

/* Resets back to frame #0 */
- (void)reset;

/* Get the current frame's image data (as 32-bit RGBA) */
- (void *)data;

- (int)width;
- (int)height;

- (unsigned int)textureId;
- (void)setTextureId:(unsigned int)tex;
@end
