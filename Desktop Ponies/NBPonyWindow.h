//
//  NBPonyWindow.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NBPony.h"
#import "NBPonyInstance.h"

@interface NBPonyWindow : NSWindow {
    NBPonyInstance *_instance;
    NSImageView *ponyView;
}

- (void)setPonyInstance:(NBPonyInstance *)instance;

@end
