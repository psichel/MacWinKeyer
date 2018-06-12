//
//  WinKeyerFormatter.h
//  MacWinKeyer
//
//  Created by Willard Myers on 2015-02-23.
//
//

#import <Foundation/Foundation.h>

@interface WinKeyerFormatter : NSFormatter

+ (BOOL)isAcceptable:(unichar)character;

@end
