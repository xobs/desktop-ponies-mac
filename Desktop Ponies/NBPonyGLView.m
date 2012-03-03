//
//  NBPonyGLView.m
//  Desktop Ponies
//
//  Created by Sean Cross on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <OpenGL/glu.h>
#include <sys/time.h>
#import "NBPonyGLView.h"


static long long getTimeMillis(void) {
    struct timeval time;
    gettimeofday(&time, NULL);
    return (time.tv_sec * 1000) + (time.tv_usec / 1000);
}


#pragma mark ---- OpenGL Utils ----
// ---------------------------------

@implementation NBPonyGLView

// pixel format definition
+ (NSOpenGLPixelFormat*) basicPixelFormat
{
    NSOpenGLPixelFormatAttribute attributes [] = {
        NSOpenGLPFAWindow,
        NSOpenGLPFADoubleBuffer,	// double buffered
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16, // 16 bit depth buffer
        (NSOpenGLPixelFormatAttribute)nil
    };
    return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
}


- (void)drawFluttershy {
    GLuint textureID;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    // Disable lighting
	//glDisable( GL_LIGHTING );
    
    textureID = [fluttershy textureId];
    if (!textureID) {
        // Disable dithering
        glDisable( GL_DITHER );
        
        // Disable blending (for now)
        glDisable( GL_BLEND );
        
        // Disable depth testing
        //glDisable( GL_DEPTH_TEST );
        
        // NOTE: If your comp doesn't support GL_NV_texture_rectangle, you can try
        // using GL_EXT_texture_rectangle if you want, it should work fine.
        
        // Enable the texture rectangle extension
        glEnable( GL_TEXTURE_RECTANGLE_ARB );
        

        // Generate one texture ID
        glGenTextures( 1, &textureID );
    
        // Bind the texture using GL_TEXTURE_RECTANGLE_NV
        glBindTexture( GL_TEXTURE_RECTANGLE_ARB, textureID );
    
        // Enable bilinear filtering on this texture
        //glTexParameteri( GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        //glTexParameteri( GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    
        // Write the 32-bit RGBA texture buffer to video memory
        glTexImage2D( GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA,
                 [fluttershy width], [fluttershy height],
                 0, GL_RGBA, GL_UNSIGNED_BYTE, [fluttershy data]);
        
        [fluttershy setTextureId:textureID];
    }
    
    
    
    glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_TEXTURE_2D);
    
    
    int x = 400;
    int y = 500;
    
	// Bind the texture to the polygons
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureID);
    
    
    
	glPushMatrix();
    
	glLoadIdentity();
	glTranslatef(x, y, 0);
	glScalef(scaleX, scaleY, 1.0);
    
	// Render a quad
	// Instead of the using (s,t) coordinates, with the  GL_NV_texture_rectangle
	// extension, you need to use the actual dimensions of the texture.
	// This makes using 2D sprites for games and emulators much easier now
	// that you won't have to convert :)
	//
	// convert the coordinates so that the bottom left corner changes to
	// (0, 0) -> (1, 1) and the top right corner changes from (1, 1) -> (0, 0)
	// we will use this new coordinate system to calculate the location of the sprite
	// in the world coordinates to do the rotation and scaling. This mapping is done in
	// order to make implementation simpler in this class and let the caller keep using
	// the standard OpenGL coordinates system (bottom left corner at (0, 0))
	glBegin(GL_QUADS);
    glTexCoord2i(0, 0);
    glVertex2i(0, 0);
    
    glTexCoord2i(0, [fluttershy height]);
    glVertex2i(0, [fluttershy height]);
    
    glTexCoord2i([fluttershy width], [fluttershy height]);
    glVertex2i([fluttershy width], [fluttershy height]);
    
    glTexCoord2i([fluttershy width], 0);
    glVertex2i([fluttershy width], 0);
	glEnd();
    
	glPopMatrix();
}



// per-window timer function, basic time based animation preformed here
- (void)animationTimer:(NSTimer *)timer
{
    long long this = getTimeMillis();
    
	// clear our drawable
	glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [fluttershy tick:(this-last)];
    [self drawFluttershy];
    [[self openGLContext] flushBuffer];
    
    last = this;
}


- (void)set2DMode:(NSSize)size
{
    GLint iViewport[4];
    
    //glViewport(0, 0, (GLsizei) size.width, (GLsizei) size.height);
    
	// Get a copy of the viewport
	glGetIntegerv( GL_VIEWPORT, iViewport );
    
    
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
    
	// Set up the orthographic projection to match the viewport
	glOrtho( iViewport[0], iViewport[0] + iViewport[2],
            iViewport[1] + iViewport[3], iViewport[1], -1, 1 );
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
    
	// Make sure depth testing and lighting are disabled for 2D rendering until
	// we are finished rendering in 2D
	glDisable( GL_DEPTH_TEST );
	glDisable( GL_LIGHTING );
}

#pragma mark -
#pragma mark OS X init functions

- (void) prepareOpenGL
{
    const GLint swapInt = 1;
    const GLint zeroOpacity = 0;
    
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; // set to vbl sync    
    [[self openGLContext] setValues:&zeroOpacity forParameter:NSOpenGLCPSurfaceOpacity];

	glShadeModel(GL_FLAT);
    	
	glClearColor(1.0f, 1.0f, 1.0f, 0.0f);

    [self set2DMode:[self frame].size];
}

-(id) initWithFrame: (NSRect) frameRect
{
	NSOpenGLPixelFormat * pf = [NBPonyGLView basicPixelFormat];
	self = [super initWithFrame: frameRect pixelFormat: pf];
    return self;
}

- (BOOL)isOpaque {
    return NO;
}

- (void)startup
{
    /*
    // set start values...
	rVel[0] = 0.3; rVel[1] = 0.1; rVel[2] = 0.2; 
	rAccel[0] = 0.003; rAccel[1] = -0.005; rAccel[2] = 0.004;
     */
	time = CFAbsoluteTimeGetCurrent ();  // set animation time start time

    
    fluttershy = [[NBGraphicsSequence alloc] initWithPath:@"/Users/smc/Downloads/Desktop Ponies V1.39/Rarity/rarity-dramacouch-left1.gif"];
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    last = getTimeMillis();

	// start animation timer
	timer = [NSTimer timerWithTimeInterval:(1.0f/60.0f) target:self selector:@selector(animationTimer:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode]; // ensure timer fires during resize
}

@end
