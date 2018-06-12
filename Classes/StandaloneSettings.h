//
//  StandaloneSettings.h
//  MacWinKeyer
//
//  Created by Willard Myers on 2015-02-27.
//
//

#import <Foundation/Foundation.h>

@interface StandaloneSettings : NSObject

- (void)decodeWK2Eeprom:(NSData*)data;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *wk2EepromData;

- (void)decodeWK3Eeprom:(NSData*)data;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *wk3EepromData;

@end
