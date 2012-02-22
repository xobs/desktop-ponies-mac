//
//  NBPony.m
//  Desktop Ponies
//
//  Created by Sean Cross on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBPony.h"
#import "NBPonyPhrase.h"
#import "NBPonyEffect.h"
#import "NBPonyBehavior.h"

@implementation NBPony

- (id)initWithPath:(NSString *)path
{
    if (!(self = [super init]))
        return nil;
    
    NSArray *fields;
    NSError *e;

    NSMutableArray *behaviorsTemp = [[NSMutableArray alloc] init];
    NSMutableArray *phrasesTemp = [[NSMutableArray alloc] init];
    NSMutableArray *effectsTemp = [[NSMutableArray alloc] init];
    NSMutableDictionary *tempDict;
    
    NSString *iniFile = [path stringByAppendingPathComponent:@"pony.ini"];
    
    NSString *iniFileContents;
    
    iniFileContents = [NSString stringWithContentsOfFile:iniFile encoding:NSUTF8StringEncoding error:&e];
    if (!iniFileContents)
        iniFileContents = [NSString stringWithContentsOfFile:iniFile encoding:NSUnicodeStringEncoding error:&e];
    if (!iniFileContents)
        iniFileContents = [NSString stringWithContentsOfFile:iniFile encoding:NSUTF16LittleEndianStringEncoding error:&e];
    if (!iniFileContents)
        iniFileContents = [NSString stringWithContentsOfFile:iniFile encoding:NSWindowsCP1252StringEncoding error:&e];
    if (!iniFileContents)
        iniFileContents = [NSString stringWithContentsOfFile:iniFile encoding:NSUTF16BigEndianStringEncoding error:&e];
    if (!iniFileContents) {
        NSLog(@"Unrecognized string encoding on file %@", iniFile);
    }
    
    fields = [iniFileContents csvRows];
    
    for (NSArray *columns in fields) {
        NSString *key = [[columns objectAtIndex:0] lowercaseString];
        if ([key hasPrefix:@"'"])
            ; // Comment line
        
        else if ([key isEqualToString:@"name"]) {
            _name = [[columns objectAtIndex:1] copy];
        }
        
        else if ([key isEqualToString:@"scale"]) {
            _scale = [[columns objectAtIndex:1] doubleValue];
        }
        
        else if ([key isEqualToString:@"behavior"]) {
            NBPonyBehavior *behavior = [NBPonyBehavior arrayToPonyBehavior:columns path:path];
            if (behavior)
                [behaviorsTemp addObject:behavior];
        }
        
        else if ([key isEqualToString:@"categories"]) {
            int i;
            NSMutableArray *categoriesTemp = [[NSMutableArray alloc] init];
            for (i=1; i<[columns count]; i++)
                [categoriesTemp addObject:[[columns objectAtIndex:i] lowercaseString]];
            _categories = [[NSArray alloc] initWithArray:categoriesTemp];
            [categoriesTemp release];
        }
        
        else if ([key isEqualToString:@"speak"]) {
            NBPonyPhrase *phrase = [NBPonyPhrase arrayToPonyPhrase:columns];
            if (phrase)
                [phrasesTemp addObject:phrase];
        }
        
        else if ([key isEqualToString:@"effect"]) {
            NBPonyEffect *effect = [NBPonyEffect arrayToPonyEffect:columns path:path];
            if (effect)
                [effectsTemp addObject:effect];
        }
        
        else {
            NSLog(@"Warning: Unrecognized command \"%@\" in file %@", key, path);
        }
    }
    
    tempDict = [[NSMutableDictionary alloc] init];
    
    
    [tempDict removeAllObjects];
    for (NBPonyPhrase *phrase in phrasesTemp) {
        if ([phrase name])
            [tempDict setObject:phrase forKey:[phrase name]];
        else
            NSLog(@"Not copying over a phrase, as it's got no name");
    }
    _phrases = [[NSDictionary alloc] initWithDictionary:tempDict];
    [phrasesTemp release];
    
    
    [tempDict removeAllObjects];
    for (NBPonyBehavior *behavior in behaviorsTemp) {
        if ([behavior name])
            [tempDict setObject:behavior forKey:[behavior name]];
    }
    _behaviors = [[NSDictionary alloc] initWithDictionary:tempDict];
    [behaviorsTemp release];
    
    
    [tempDict removeAllObjects];
    for (NBPonyEffect *effect in effectsTemp) {
        if ([effect name] && [effect resolveBehavior:self])
            [tempDict setObject:effect forKey:[effect name]];
    }
    _effects = [[NSDictionary alloc] initWithDictionary:tempDict];
    [effectsTemp release];
    
    
    [tempDict release];
    
    return self;
}


#pragma mark -
#pragma mark Accessors
- (NSString *)name
{
    return _name;
}

- (NSDictionary *)behaviors
{
    return _behaviors;
}

- (NBPonyBehavior *)behaviorNamed:(NSString *)name
{
    return [_behaviors objectForKey:name];
}

@end




@implementation NSString (ParsingExtensions)

-(NSArray *)csvRows {
    NSMutableArray *rows = [NSMutableArray array];
    
    // Get newline character set
    NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
    
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@",\"{}"];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
    
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) {        
        BOOL insideQuotes = NO;
        BOOL insideBraces = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
        NSMutableString *currentColumn = [NSMutableString string];
        while ( !finishedRow ) {
            NSString *tempString;
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
                [currentColumn appendString:tempString];
            }
            
            if ( [scanner isAtEnd] ) {
                if ( ![currentColumn isEqualToString:@""] )
                    [columns addObject:currentColumn];
                finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) {
                if ( insideQuotes || insideBraces ) {
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
                else {
                    // End of row
                    if ( ![currentColumn isEqualToString:@""] )
                        [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ( [scanner scanString:@"{" intoString:NULL] && !insideBraces && [currentColumn length] == 0 ) {
                insideBraces = YES;
            }
            else if ( [scanner scanString:@"}" intoString:NULL] && insideBraces ) {
                insideBraces = NO;
            }
            else if ( [scanner scanString:@"\"" intoString:NULL] ) {
                if ( (insideQuotes && [scanner scanString:@"\"" intoString:NULL]) 
                    || (insideBraces && [scanner scanString:@"\"" intoString:NULL]) ) {
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""]; 
                }
                else {
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
                }
            }
            else if ( [scanner scanString:@"," intoString:NULL] ) {  
                if ( insideQuotes || insideBraces ) {
                    [currentColumn appendString:@","];
                }
                else {
                    // This is a column separating comma
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                }
            }
        }
        if ( [columns count] > 0 ) [rows addObject:columns];
    }
    
    return rows;
}

@end
