//
//  NBPonyPhrase.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBPonyPhrase.h"

@implementation NBPonyPhrase

+ (NBPonyPhrase *)arrayToPonyPhrase:(NSArray *)array
{
    return [[[NBPonyPhrase alloc] initWithArray:array] autorelease];
}

- (id)initWithArray:(NSArray *)array
{
    if (!(self = [super init]))
        return nil;
    
    if ([array count] == 2) {
        name = [[array objectAtIndex:1] copy];
        line = [[array objectAtIndex:1] copy];
        sounds = [[NSArray alloc] init];
        skip = false;
    }
    else if ([array count] == 5) {
        name = [[array objectAtIndex:1] copy];
        line = [[array objectAtIndex:2] copy];
#warning Parse brace-delimited arrays here
        sounds = [[NSArray alloc] initWithObjects:[array objectAtIndex:3], nil];
        skip = [[array objectAtIndex:4] boolValue];
    }
    else {
        name = nil;
        line = nil;
        sounds = nil;
        NSLog(@"Warning: Invalid phrase definition");
        [self release];
    }
    
    return self;
}

/*
- (id)retain
{
    [name retain];
    [line retain];
    [sounds retain];
    return self;
}
- (oneway void)release
{
    [name release];
    [line release];
    [sounds release];
}
*/


- (NSString *)name
{
    return name;
}

- (NSString *)line
{
    return line;
}

- (NSArray *)sounds
{
    return sounds;
}

- (BOOL)skip
{
    return skip;
}

- (NSString *)description
{
    return name;
}

@end
