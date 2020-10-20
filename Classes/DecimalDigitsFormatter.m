//
//  DecimalDigitsFormatter.m
//  MacWinKeyer
//
//  Created by Willard Myers on 2020-10-20.
//

#import "DecimalDigitsFormatter.h"

@implementation DecimalDigitsFormatter

- (NSString*)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass: [NSString class]]) {
        return ((NSString*)obj).uppercaseString;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%ld", ((NSNumber*)obj).integerValue];
    } else {
        return nil;
    }
}

- (BOOL)getObjectValue:(out id  _Nullable __autoreleasing *)obj
             forString:(NSString *)string
      errorDescription:(out NSString *__autoreleasing  _Nullable *)error
{
    *obj = @(string.integerValue);
    return YES;
}

// Accept only decimal digits
- (BOOL)isPartialStringValid:(NSString *__autoreleasing  _Nonnull *)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString *__autoreleasing  _Nullable *)error
{
    BOOL isValid = YES;
    if ((*partialStringPtr).length == 0) {
        if (error) {
            *error = @"Number entry cannot be empty";
        }
        *partialStringPtr = [origString copy]; // Must copy here!
        *proposedSelRangePtr = origSelRange;
        isValid = NO;
    }
    for (NSUInteger i = 0; i < (*partialStringPtr).length; ++i) {
        unichar c = [*partialStringPtr characterAtIndex:i];
        if (![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c]) {
            if (error) {
                // Set error string to the unacceptable character
                *error = [NSString stringWithFormat:@"%C", c];
            }
            *partialStringPtr = [origString copy]; // Must copy here!
            *proposedSelRangePtr = origSelRange;
            isValid = NO;
            break;
        }
    }
    return isValid;
}

@end
