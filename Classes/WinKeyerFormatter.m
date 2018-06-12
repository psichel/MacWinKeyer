//
//  WinKeyerFormatter.m
//  MacWinKeyer
//
//  Created by Willard Myers on 2015-02-23.
//
//

#import "WinKeyerFormatter.h"

@implementation WinKeyerFormatter

// Set of characters handled natively by WinKeyer
static NSCharacterSet* sWinKeyerCharacterSet = nil;
+ (void)initialize
{
    NSMutableCharacterSet* aSet = [[NSCharacterSet uppercaseLetterCharacterSet] mutableCopy];
    [aSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    // Per 6/1/2006 Prosign Key Assignment table excluding 'EE' items
    // Omitting characters overriden by self
    [aSet addCharactersInString:@"\"$'()+-/<=>@"];
    // Others discovered by trial and error
    [aSet addCharactersInString:@"[]|;:`!%_"];
    // And of course punctuation, and wordspace
    // '|' does half-space and isn't echoed
    [aSet addCharactersInString:@",.? "];
    sWinKeyerCharacterSet = [aSet copy];
}

+ (BOOL)isAcceptable:(unichar)character
{
    return [sWinKeyerCharacterSet characterIsMember:character];
}

- (NSString*)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass: [NSString class]]) {
        return [(NSString*)obj uppercaseString];
    } else {
        return nil;
    }
}

- (BOOL)getObjectValue:(id*)obj forString:(NSString*)string errorDescription:(NSString**)errorString
{
    *obj = [string uppercaseString];
    return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString *__autoreleasing *)newString errorDescription:(NSString *__autoreleasing *)error
{
    // Called each time user types a character
    BOOL didEdit = NO;
    NSString* candidateResult = [partialString uppercaseString];
    NSMutableString* result = [NSMutableString stringWithCapacity:candidateResult.length];
    for (NSUInteger i = 0; i < candidateResult.length; ++i) {
        unichar c = [candidateResult characterAtIndex:i];
        if ([sWinKeyerCharacterSet characterIsMember:c]) {
            [result appendString:[NSString stringWithFormat:@"%c", c]];
            didEdit = YES;
        } else {
            didEdit = YES;
        }
    }
    *newString = result;
    return !didEdit;
}

@end
