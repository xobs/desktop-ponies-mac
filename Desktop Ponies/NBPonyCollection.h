//
//  NBPonyCollection.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBPony.h"

@interface NBPonyCollection : NSObject {
    NSMutableDictionary *ponies;
}


- (int)loadPonies:(NSString *)path;
- (NBPony *)ponyNamed:(NSString *)name;

@end
