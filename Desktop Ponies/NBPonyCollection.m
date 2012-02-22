//
//  NBPonyCollection.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBPonyCollection.h"
#import "NBPony.h"

@implementation NBPonyCollection

- (id)init {
    if (self = [super init]) {
        ponies = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (int)loadPonies:(NSString *)path
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSArray *dirValues = [localFileManager contentsOfDirectoryAtPath:path error:nil];
    
    for (NSString *dirname in dirValues) {
        NSString *fullPath = [path stringByAppendingPathComponent:dirname];
        NSString *ponyIni = [fullPath stringByAppendingPathComponent:@"pony.ini"];
        if ([localFileManager fileExistsAtPath:ponyIni]) {
            NBPony *tmp = [[NBPony alloc] initWithPath:fullPath];
            if (tmp && [tmp name]) {
                [ponies setObject:tmp forKey:[tmp name]];
            }
            else if (tmp) {
                NSLog(@"Warning: Pony %@ has no name", fullPath);
            }
            [tmp release];
        }
    }
    [localFileManager release];
    
    return 0;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"NBPonyCollection with %d ponies", [ponies count]];
}

- (NBPony *)ponyNamed:(NSString *)name
{
    return [ponies objectForKey:name];
}

@end
