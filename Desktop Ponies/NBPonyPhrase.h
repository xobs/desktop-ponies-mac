//
//  NBPonyPhrase.h
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBPonyPhrase : NSObject {
    NSString *name;
    NSString *line;
    NSArray *sounds;
    BOOL skip;
}

+ (NBPonyPhrase *)arrayToPonyPhrase:(NSArray *)array;
- (id)initWithArray:(NSArray *)array;
- (NSString *)name;
- (NSString *)line;
- (NSArray *)sounds;
- (BOOL)skip;

@end
