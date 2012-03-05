//
//  NBPonyGLView.m
//  Desktop Ponies
//
//  Created by Sean Cross on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <OpenGL/glu.h>
#import "NBPonyGLView.h"
#import "NBGraphicsSequence.h"

@implementation NBPonyGLView


#pragma mark -
#pragma mark Pony utils

- (void)addPonyInstance:(NBPonyInstance *)instance {
    [instances addObject:instance];
}

- (void)removePonyInstance:(NBPonyInstance *)instance {
    [instances removeObject:instance];
}

#pragma mark ---- OpenGL Utils ----
// ---------------------------------


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


- (void)drawInstance:(NBPonyInstance *)instance {
    NSPoint origin = [instance origin];
    NBGraphicsSequence *sequence = [instance image];
    int frame = [instance currentFrame];
    GLuint textureID;
    float scaleX = 1.0;
    float scaleY = 1.0;
    float x = origin.x;
    float y = origin.y;
    
    // Disable lighting
	//glDisable( GL_LIGHTING );
    
    textureID = [sequence textureIdForFrame:frame];
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
    
        // Enable nearest-neighbor filtering on this texture
        glTexParameteri( GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
        glTexParameteri( GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    
        // Write the 32-bit RGBA texture buffer to video memory
        glTexImage2D( GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA,
                 [sequence width], [sequence height],
                     0, GL_RGBA, GL_UNSIGNED_BYTE, [sequence dataForFrame:frame]);
        
        [sequence setTextureId:textureID forFrame:frame];
    }
    
    // Enable alpha blending
    glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
	// Bind the texture to the polygons
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureID);
    
    
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
    
    glTexCoord2i(0, [sequence height]);
    glVertex2i(0, [sequence height]);
    
    glTexCoord2i([sequence width], [sequence height]);
    glVertex2i([sequence width], [sequence height]);
    
    glTexCoord2i([sequence width], 0);
    glVertex2i([sequence width], 0);
	glEnd();    
}

// per-window timer function, basic time based animation preformed here
- (void)redraw
{
	// clear our drawable
	glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    for (NBPonyInstance *instance in instances)
        [self drawInstance:instance];
    
    [[self openGLContext] flushBuffer];
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
    
    glEnable(GL_BLEND);
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
    instances = [[NSMutableArray alloc] init];
    glClearColor(0.0, 0.0, 0.0, 0.0);
}

@end
