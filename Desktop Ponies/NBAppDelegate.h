//
//  NBAppDelegate.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NBPonyCollection.h"
#import "NBPonyWindow.h"

@interface NBAppDelegate : NSObject <NSApplicationDelegate> {
    NBPonyCollection *ponyCollection;
    NBPonyWindow *testWindow;
    IBOutlet NSImageView *testOutput;
}

@property (assign) IBOutlet NSWindow *window;

@end
