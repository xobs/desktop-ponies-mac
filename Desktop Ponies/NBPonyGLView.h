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
#import "NBGraphicsSequence.h"

typedef struct {
    GLdouble x,y,z;
} recVec;

typedef struct {
	recVec viewPos; // View position
	recVec viewDir; // View direction vector
	recVec viewUp; // View up direction
	recVec rotPoint; // Point to rotate about
	GLdouble aperture; // pContextInfo->camera aperture
	GLint viewWidth, viewHeight; // current window/screen height and width
} recCamera;


@interface NBPonyGLView : NSOpenGLView {        
    NSTimer* timer;
	CFAbsoluteTime time;
    
    NBGraphicsSequence *fluttershy;
    long long last;
}

- (void)startup;
- (void)animationTimer:(NSTimer *)timer;

@end
