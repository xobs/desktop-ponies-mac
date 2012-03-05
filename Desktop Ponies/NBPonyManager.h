//
//  NBPonyManager.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBPonyCollection.h"
#import "NBGraphicsSequence.h"
#import "NBPony.h"
#import "NBPonyInstance.h"
#import "NBPonyGLView.h"

@interface NBPonyManager : NSObject {
    NBPonyCollection    *_collection;
    NSMutableArray      *_active;
    NSWindow            *mainWindow;
    NBPonyGLView        *mainView;
}

- (NBPonyManager *)initWithPonyCollection:(NBPonyCollection *)collection;
- (BOOL)addPonyNamed:(NSString *)name;
- (BOOL)addPony:(NBPony *)pony;
- (NBPonyInstance *)ponyNamed:(NSString *)name;
- (BOOL)removePony:(NBPony *)pony;
- (BOOL)removePonyNamed:(NSString *)name;

- (int)tickAll:(long long)elapsed;
- (void)redraw;

@end
