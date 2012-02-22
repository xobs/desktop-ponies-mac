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
    NSArray *_orderedBehaviors;
    NSDictionary *_phrases;
    NSDictionary *_effects;
    double _scale;
    
    NSUInteger _behaviorCount;
    double _behaviorProbabilityTotal;
}

- (id)initWithPath:(NSString *)path;
- (NSDictionary *)behaviors;
- (NSUInteger)behaviorCount;
- (double)behaviorProbabilityTotal;
- (NBPonyBehavior *)behaviorNamed:(NSString *)name;
- (NSArray *)behaviorsAsArray;
- (NSString *)name;
- (double)scale;

@end

@interface NSString (ParsingExtensions)
-(NSArray *)csvRows;
@end