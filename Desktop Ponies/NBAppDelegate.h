//
//  NBAppDelegate.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NBPonyCollection.h"
#import "NBPonyManager.h"

@interface NBAppDelegate : NSObject <NSApplicationDelegate> {
    NBPonyCollection *ponyCollection;
    NBPonyManager *manager;
    NSTimer *tickTimer;
    long long last;
}

- (void)doTick:(id)sender;

@end
