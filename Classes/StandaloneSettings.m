//
//  StandaloneSettings.m
//  MacWinKeyer
//
//  Created by Willard Myers on 2015-02-27.
//
//

#import "Preferences.h"
#import "StandaloneSettings.h"
#import "WinKeyerRegisters.h"
#import "WinKeyerTypes.h"

static const uint8 ASCII_TO_MORSE[96]	=
{ 0x1c,0x01,0x52,0x01,0xc8,0x01,0x01,0x5E,		    // " !"#$%&'"
    0x2d,0x6d,0x01,0x2a,0x73,0x61,0x6a,0x29,		// "()*+,-./"
    0x3f,0x3e,0x3c,0x38,0x30,0x20,0x21,0x23,		// "01234567"
    0x27,0x2f,0x2d,0x1a,0x2a,0x31,0x68,0x4c,		// "89:;<=>?"
    0x56,0x06,0x11,0x15,0x09,0x02,0x14,0x0b,		// "@ABCDEFG"
    0x10,0x04,0x1e,0x0d,0x12,0x07,0x05,0x0f,		// "HIJKLMNO"
    0x16,0x1b,0x0a,0x08,0x03,0x0c,0x18,0x0e,		// "PQRSTUVW"
    0x19,0x1d,0x13,0x22,0x29,0x2d,0x01,0x01,		// "XYZ[\]^_"
    0x01,0x06,0x11,0x15,0x09,0x02,0x14,0x0b,		// "'abcdefg"
    0x10,0x04,0x1e,0x0d,0x12,0x07,0x05,0x0f,		// "hilklmno"
    0x16,0x1b,0x0a,0x08,0x03,0x0c,0x18,0x0e,		// "pqrstuvw"
    0x19,0x1d,0x13,0x01,0x2c,0x01,0x01,0x01			// "xyz{|}  "
};

@implementation StandaloneSettings

- (void)awakeFromNib
{
}

#pragma mark - Populate EEPROM from preferences

- (NSData*)wk2EepromData
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:standaloneSettingsKeyPath];
    //NSLog(@"WinkeyerUsb:writeEeprom");
    WK2EEPROM* eeprom = calloc(1, sizeof(WK2EEPROM));
    eeprom->magic = 0xA5;
    eeprom->modereg = encodeModeRegisterFromDict(preferences);
    eeprom->stconst = encodeWK2SidetoneRegisterFromDict(preferences);
    eeprom->kweight = [preferences[KeyWeight] integerValue];
    eeprom->lead_time = [preferences[PushToTalkLeadDelay] integerValue];
    eeprom->tail_time = [preferences[PushToTalkTailDelay] integerValue];
    eeprom->min_wpm = [preferences[SpeedMinimum] integerValue];
    eeprom->wpm_range = [preferences[SpeedRange] integerValue];
    eeprom->xtnd = [preferences[KeyFirstExtension] integerValue];
    eeprom->kcomp = [preferences[KeyCompensation] integerValue];
    eeprom->farnswpm = [preferences[SpeedFarnsworth] integerValue];
    eeprom->sampadj = [preferences[PaddleSwitchpoint] integerValue];
    eeprom->ratio = [preferences[KeyRatio] integerValue];
    eeprom->pincfg = encodePinConfigurationRegisterFromDict(preferences);
    eeprom->k12mode = encodeWK2Extension1RegisterFromDict(preferences);
    eeprom->cmdwpm = [preferences[SpeedCommanded] integerValue];

    eeprom->freeptr = 0x18;
    [self appendMessages:eeprom from:preferences];

    NSData* eepromData = [NSData dataWithBytes:eeprom length:sizeof(WK2EEPROM)];
    free(eeprom);
    return eepromData;
}

- (NSData*)wk3EepromData
{
    NSDictionary* user1Dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:standaloneSettings0KeyPath];
    NSDictionary* user2Dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:standaloneSettings1KeyPath];
    WK3EEPROM* eeprom = calloc(1, sizeof(WK3EEPROM));
    eeprom->modereg1 = encodeModeRegisterFromDict(user1Dict);
    eeprom->modereg2 = encodeModeRegisterFromDict(user2Dict);
    eeprom->farnswpm1 = [user1Dict[SpeedFavorite] integerValue];
    eeprom->farnswpm2 = [user2Dict[SpeedFavorite] integerValue];
    eeprom->stconst1 = encodeWK3SidetoneRegisterFromDict(user1Dict);
    eeprom->stconst2 = encodeWK3SidetoneRegisterFromDict(user2Dict);
    eeprom->weight1 = [user1Dict[KeyWeight] integerValue];
    eeprom->weight2 = [user2Dict[KeyWeight] integerValue];
    eeprom->lead_time1 = [user1Dict[PushToTalkLeadDelay] integerValue];
    eeprom->lead_time2 = [user2Dict[PushToTalkLeadDelay] integerValue];
    eeprom->tail_time1 = [user1Dict[PushToTalkTailDelay] integerValue];
    eeprom->tail_time2 = [user2Dict[PushToTalkTailDelay] integerValue];
    eeprom->minwpm1 = [user1Dict[SpeedMinimum] integerValue];
    eeprom->minwpm2 = [user2Dict[SpeedMinimum] integerValue];
    eeprom->wpmrange1 = [user1Dict[SpeedRange] integerValue];
    eeprom->wpmrange2 = [user2Dict[SpeedRange] integerValue];
    eeprom->x2mode1 = encodeExtension2RegisterFromDict(user1Dict);
    eeprom->x2mode2 = encodeExtension2RegisterFromDict(user2Dict);
    eeprom->kcomp1 = [user1Dict[KeyCompensation] integerValue];
    eeprom->kcomp2 = [user2Dict[KeyCompensation] integerValue];
    eeprom->farnswpm1 = [user1Dict[SpeedFarnsworth] integerValue];
    eeprom->farnswpm2 = [user2Dict[SpeedFarnsworth] integerValue];
    eeprom->sampadj1 = [user1Dict[PaddleSwitchpoint] integerValue];
    eeprom->sampadj2 = [user2Dict[PaddleSwitchpoint] integerValue];
    eeprom->ratio1 = [user1Dict[KeyRatio] integerValue];
    eeprom->ratio2 = [user2Dict[KeyRatio] integerValue];
    eeprom->pincfg1 = encodePinConfigurationRegisterFromDict(user1Dict);
    eeprom->pincfg2 = encodePinConfigurationRegisterFromDict(user2Dict);
    eeprom->x1mode1 = encodeWK3Extension1RegisterFromDict(user1Dict);
    eeprom->x1mode2 = encodeWK3Extension1RegisterFromDict(user2Dict);
    eeprom->cmdwpm1 = [user1Dict[SpeedCommanded] integerValue];
    eeprom->cmdwpm2 = [user2Dict[SpeedCommanded] integerValue];
    eeprom->freeptr = 0x0F;
    [self packMessage:user1Dict[Message1] startingAddress:&(eeprom->msgptr1) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message2] startingAddress:&(eeprom->msgptr2) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message3] startingAddress:&(eeprom->msgptr3) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message4] startingAddress:&(eeprom->msgptr4) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message5] startingAddress:&(eeprom->msgptr5) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message6] startingAddress:&(eeprom->msgptr6) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message7] startingAddress:&(eeprom->msgptr7) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message8] startingAddress:&(eeprom->msgptr8) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message9] startingAddress:&(eeprom->msgptr9) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message10] startingAddress:&(eeprom->msgptr10) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message11] startingAddress:&(eeprom->msgptr11) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[Message12] startingAddress:&(eeprom->msgptr12) intoWK3EEPROM:eeprom];
    [self packMessage:user1Dict[MessageMyCall] startingAddress:&(eeprom->mycallptr1) intoWK3EEPROM:eeprom];
    [self packMessage:user2Dict[MessageMyCall] startingAddress:&(eeprom->mycallptr2) intoWK3EEPROM:eeprom];
    
    NSData* eepromData = [NSData dataWithBytes:eeprom length:sizeof(WK3EEPROM)];
    free(eeprom);
    return eepromData;
}

#pragma mark - Interpret EEPROM into preferences

- (void)decodeWK2Eeprom:(NSData*)data
{
    NSAssert((data.length == 256), @"Corrupted WK2 EEPROM");
    const WK2EEPROM* eeprom = (const WK2EEPROM*)data.bytes;
    //TODO Test eeprom->magic
    NSMutableDictionary* preferences = [NSMutableDictionary dictionary];
    decodeModeRegisterIntoDict(eeprom->modereg, preferences);
    preferences[KeyRatio] = @(eeprom->ratio);
    preferences[KeyWeight] = @(eeprom->kweight);
    preferences[KeyCompensation] = @(eeprom->kcomp);
    preferences[KeyFirstExtension] = @(eeprom->xtnd);
    preferences[PushToTalkLeadDelay] = @(eeprom->lead_time);
    preferences[PushToTalkTailDelay] = @(eeprom->tail_time);
    preferences[PaddleSwitchpoint] = @(eeprom->sampadj);
    preferences[SpeedFarnsworth] = @(eeprom->farnswpm);
    preferences[SpeedRange] = @(eeprom->wpm_range);
    preferences[SpeedMinimum] = @(eeprom->min_wpm);
    preferences[SpeedCommanded] = @(eeprom->cmdwpm);
    decodeWK2SidetoneRegisterIntoDict(eeprom->stconst, preferences);
    decodePinConfigurationRegisterIntoDict(eeprom->pincfg, preferences);
    decodeWK2Extension1RegisterIntoDict(eeprom->k12mode, preferences);
    const uint8 offset = 0x18;
    preferences[Message1] = [self decodeMessageAtAddress:eeprom->msgptr1 inBuffer:eeprom->msgs withOffset:offset];
    preferences[Message2] = [self decodeMessageAtAddress:eeprom->msgptr2 inBuffer:eeprom->msgs withOffset:offset];
    preferences[Message3] = [self decodeMessageAtAddress:eeprom->msgptr3 inBuffer:eeprom->msgs withOffset:offset];
    preferences[Message4] = [self decodeMessageAtAddress:eeprom->msgptr4 inBuffer:eeprom->msgs withOffset:offset];
    preferences[Message5] = [self decodeMessageAtAddress:eeprom->msgptr5 inBuffer:eeprom->msgs withOffset:offset];
    preferences[Message6] = [self decodeMessageAtAddress:eeprom->msgptr6 inBuffer:eeprom->msgs withOffset:offset];
    
    [[NSUserDefaults standardUserDefaults] setObject:preferences forKey:standaloneSettingsKeyPath];
}

- (void)decodeWK3Eeprom:(NSData*)data
{
    NSAssert((data.length == (32 + 256)), @"Corrupted WK3 EEPROM");
    const WK3EEPROM* eeprom = (const WK3EEPROM*)data.bytes;
    NSMutableDictionary* user1Dict = [NSMutableDictionary dictionary];
    NSMutableDictionary* user2Dict = [NSMutableDictionary dictionary];
    decodeModeRegisterIntoDict(eeprom->modereg1, user1Dict);
    decodeModeRegisterIntoDict(eeprom->modereg2, user2Dict);
    user1Dict[SpeedFavorite] = @(eeprom->favewpm1);
    user2Dict[SpeedFavorite] = @(eeprom->favewpm2);
    decodeWK3SidetoneRegisterIntoDict(eeprom->stconst1, user1Dict);
    decodeWK3SidetoneRegisterIntoDict(eeprom->stconst2, user2Dict);
    user1Dict[KeyWeight] = @(eeprom->weight1);
    user2Dict[KeyWeight] = @(eeprom->weight2);
    user1Dict[PushToTalkLeadDelay] = @(eeprom->lead_time1);
    user2Dict[PushToTalkLeadDelay] = @(eeprom->lead_time2);
    user1Dict[PushToTalkTailDelay] = @(eeprom->tail_time1);
    user2Dict[PushToTalkTailDelay] = @(eeprom->tail_time2);
    user1Dict[SpeedMinimum] = @(eeprom->minwpm1);
    user2Dict[SpeedMinimum] = @(eeprom->minwpm2);
    user1Dict[SpeedRange] = @(eeprom->wpmrange1);
    user2Dict[SpeedRange] = @(eeprom->wpmrange2);
    decodeExtension2RegisterIntoDict(eeprom->x2mode1, user1Dict);
    decodeExtension2RegisterIntoDict(eeprom->x2mode2, user2Dict);
    user1Dict[KeyCompensation] = @(eeprom->kcomp1);
    user2Dict[KeyCompensation] = @(eeprom->kcomp2);
    user1Dict[SpeedFarnsworth] = @(eeprom->farnswpm1);
    user2Dict[SpeedFarnsworth] = @(eeprom->farnswpm2);
    user1Dict[PaddleSwitchpoint] = @(eeprom->sampadj1);
    user2Dict[PaddleSwitchpoint] = @(eeprom->sampadj2);
    user1Dict[KeyRatio] = @(eeprom->ratio1);
    user2Dict[KeyRatio] = @(eeprom->ratio2);
    decodePinConfigurationRegisterIntoDict(eeprom->pincfg1, user1Dict);
    decodePinConfigurationRegisterIntoDict(eeprom->pincfg2, user2Dict);
    decodeWK3Extension1RegisterIntoDict(eeprom->x1mode1, user1Dict);
    decodeWK3Extension1RegisterIntoDict(eeprom->x2mode2, user2Dict);
    user1Dict[SpeedCommanded] = @(eeprom->cmdwpm1);
    user2Dict[SpeedCommanded] = @(eeprom->cmdwpm2);
    const uint8 offset = 0x0F;
    user1Dict[Message1] = [self decodeMessageAtAddress:eeprom->msgptr1 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message2] = [self decodeMessageAtAddress:eeprom->msgptr2 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message3] = [self decodeMessageAtAddress:eeprom->msgptr3 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message4] = [self decodeMessageAtAddress:eeprom->msgptr4 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message5] = [self decodeMessageAtAddress:eeprom->msgptr5 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message6] = [self decodeMessageAtAddress:eeprom->msgptr6 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message7] = [self decodeMessageAtAddress:eeprom->msgptr7 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message8] = [self decodeMessageAtAddress:eeprom->msgptr8 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message9] = [self decodeMessageAtAddress:eeprom->msgptr9 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message10] = [self decodeMessageAtAddress:eeprom->msgptr10 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message11] = [self decodeMessageAtAddress:eeprom->msgptr11 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[Message12] = [self decodeMessageAtAddress:eeprom->msgptr12 inBuffer:eeprom->msgs withOffset:offset];
    user1Dict[MessageMyCall] = [self decodeMessageAtAddress:eeprom->mycallptr1 inBuffer:eeprom->msgs withOffset:offset];
    user2Dict[MessageMyCall] = [self decodeMessageAtAddress:eeprom->mycallptr2 inBuffer:eeprom->msgs withOffset:offset];
    [[NSUserDefaults standardUserDefaults] setObject:user1Dict forKey:standaloneSettings0KeyPath];
    [[NSUserDefaults standardUserDefaults] setObject:user2Dict forKey:standaloneSettings1KeyPath];
}

#pragma mark - Populate EEPROM Utilities

- (void)appendMessage:(NSString*)message address:(uint8*)msgptr eeprom:(WK2EEPROM*)eeprom
{
    NSInteger messageLength = message.length;
    if (messageLength > 0 && (messageLength + eeprom->freeptr < 256)) {
        *msgptr = eeprom->freeptr;
        eeprom->freeptr += messageLength;
        [self encodeMessage:message start:*msgptr into:eeprom->msgs];
    } else {
        *msgptr = 0x10;
    }
}

- (void)appendMessages:(WK2EEPROM*)eeprom from:(NSDictionary*)preferences
{
    [self appendMessage:preferences[Message1] address:&(eeprom->msgptr1) eeprom:eeprom];
    [self appendMessage:preferences[Message2] address:&(eeprom->msgptr2) eeprom:eeprom];
    [self appendMessage:preferences[Message3] address:&(eeprom->msgptr3) eeprom:eeprom];
    [self appendMessage:preferences[Message4] address:&(eeprom->msgptr4) eeprom:eeprom];
    [self appendMessage:preferences[Message5] address:&(eeprom->msgptr5) eeprom:eeprom];
    [self appendMessage:preferences[Message6] address:&(eeprom->msgptr6) eeprom:eeprom];
}

- (void)encodeMessage:(NSString*)aMessage start:(NSUInteger)start into:(uint8*)msgs
{
    NSData* messageData = [aMessage dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSUInteger i = 0;
    const uint8* buffer = messageData.bytes;
    for (; i < messageData.length; ++i) {
        msgs[start + i - 0x18] = ASCII_TO_MORSE[buffer[i] - 0x20];
    }
    msgs[start + i - 0x18 - 1] |= 0x80; // Flags last character in message
}

/****************************************************
 * Pack Message
 ***************************************************/
//BYTE packMsg (char* sbuf, BYTE index)
- (NSInteger)encodeMessage:(NSString*)message intoBuffer:(uint8*)buffer atAddress:(const uint8)address
{
    if (message.length == 0) return 0;
    
    NSInteger index = address;
    NSData* messageData = [message dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    const uint8* sbuf = messageData.bytes;
    
    for (NSInteger i = 0; i < message.length; i++) {
        uint8 temp = sbuf[i];
        if (temp == 0xd) {  // translate CR to space
            temp = 0x20;
        }
        if (temp == 0xa) {  // translate LF to space
            temp = 0x20;
        }
        temp = ASCII_TO_MORSE[temp - 0x20];
        buffer[index++] = temp;
    }
    buffer[index-1] |= 0x80;
    
    return index - address;
}

- (void)packMessage:(NSString*)message startingAddress:(uint8*)msgPtr intoWK3EEPROM:(WK3EEPROM*)eeprom
{
    NSInteger count = [self encodeMessage:message intoBuffer:eeprom->msgs atAddress:(eeprom->freeptr - 0x0f)];
    if (count == 0) {
        *msgPtr = 0x00;
    } else {
        *msgPtr = eeprom->freeptr;
        eeprom->freeptr += count;
    }
}

#pragma mark - Interpret EEPROM Utilities

/****************************************************
 * Unpack Message
 ***************************************************/
//void unpackMsg (char* sbuf, BYTE index)
// Call with offset 0x0 for WK2, 0x0F for WK3
- (NSString*)decodeMessageAtAddress:(const uint8)address inBuffer:(const uint8*)buffer withOffset:(const uint8)offset
{
    char sbuf[256];
    NSUInteger i = 0;
    BOOL done = NO;
    NSInteger index = address;
    if (address != 0) {
        index -= offset;  // adjust index for start of msg array
        do {
            sbuf[i] = buffer[index++];
            if (sbuf[i] & 0x80) {
                sbuf[i] = [self morseToAscii:(sbuf[i] & 0x7f)];
                i++;
                done = YES;
            }
            else {
                sbuf[i] = [self morseToAscii:(sbuf[i])];
                i++;
            }
        } while (!done);
        sbuf[i] = 0;
    }
    else {
        sbuf[i] = 0;
    }
    return @(sbuf);
}

//BYTE morseToAscii (BYTE morse)
- (uint8)morseToAscii:(uint8)morse
{
    for (NSUInteger i = 0; i < 96; i++) {
        if (ASCII_TO_MORSE[i] == morse) {
            return i + 0x20;
        }
    }
    return 0;
}

@end
