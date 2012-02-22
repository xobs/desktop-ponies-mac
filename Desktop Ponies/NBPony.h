//
//  NBPony.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBPonyBehavior.h"

@interface NBPony : NSObject {
    NSString *_name;
    NSArray *_categories;
    NSDictionary *_behaviors;
    NSDictionary *_phrases;
    NSDictionary *_effects;
    double _scale;
}

- (id)initWithPath:(NSString *)path;
- (NSDictionary *)behaviors;
- (NBPonyBehavior *)behaviorNamed:(NSString *)name;
- (NSString *)name;

@end

@interface NSString (ParsingExtensions)
-(NSArray *)csvRows;
@end