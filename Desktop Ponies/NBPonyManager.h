//
//  NBPonyManager.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBPonyCollection.h"
#import "NBPony.h"
#import "NBPonyInstance.h"

@interface NBPonyManager : NSObject {
    NBPonyCollection *_collection;
    NSMutableArray *_active;
}

- (NBPonyManager *)initWithPonyCollection:(NBPonyCollection *)collection;
- (BOOL)addPonyNamed:(NSString *)name;
- (NBPonyInstance *)ponyNamed:(NSString *)name;
- (BOOL)removePony:(NBPony *)pony;
- (BOOL)removePonyNamed:(NSString *)name;

- (int)tickAll;


@end
