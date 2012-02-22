//
//  NBPonyWindow.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import "NBPony.h"
#import "NBPonyInstance.h"

@interface NBPonyWindow : NSWindow {
    NBPonyInstance *_instance;
    WebView *ponyView;
}

- (void)setPonyInstance:(NBPonyInstance *)instance;
- (void)doTick;

- (void)behaviorTimeoutExpiredForInstance:(NBPonyInstance *)instance;
- (void)performMovement:(NSSize)delta forInstance:(NBPonyInstance *)instance;
- (BOOL)shouldBounce:(NSSize)delta forInstance:(NBPonyInstance *)instance;
- (NSSize)makeBestBounce:(NSSize)delta forInstance:(NBPonyInstance *)instance;
- (void)invalidateGraphicsForInstance:(NBPonyInstance *)instance;
- (BOOL)wouldFitOnScreen:(NSSize)newSize forInstance:(NBPonyInstance *)instance;
- (void)moveToPoint:(NSPoint)point forInstance:(NBPonyInstance *)instance;

@end
