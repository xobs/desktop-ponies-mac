//
//  NBPonyGLView.h
//  Desktop Ponies
//
//  Created by Sean Cross on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import "NBPonyInstance.h"

@class NBGraphicsSequence;

@interface NBPonyGLView : NSOpenGLView {        
    NSTimer* timer;
    NSMutableArray *instances;
}

- (void)startup;
- (void)redraw;

- (void)drawInstance:(NBPonyInstance *)instance;
- (void)addPonyInstance:(NBPonyInstance *)instance;
- (void)removePonyInstance:(NBPonyInstance *)instance;

@end
