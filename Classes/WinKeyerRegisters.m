//
//  WinKeyerRegisters.m
//  MacWinKeyer
//
//  Created by Willard Myers on 2015-03-08.
//
//

#import <Foundation/Foundation.h>
#import "Preferences.h"
#import "WinKeyerTypes.h"

uint8 encodeModeRegisterFromDict(NSDictionary* preferences)
{
    uint8 modeRegister = 0x00;
    BOOL paddleWatchDog = [preferences[PaddleWatchDog] boolValue];
    if (paddleWatchDog) modeRegister |= 0x80;
    BOOL paddleEchoback = [preferences[HostPaddleEchoback] boolValue];
    if (paddleEchoback) modeRegister |= 0x40;
    PaddleModeType paddleMode = [preferences[PaddleMode] integerValue];
    switch (paddleMode) {
        case PaddleModeIambicB: break;
        case PaddleModeIambicA: modeRegister |= 0x10; break;
        case PaddleModeUltimatic: modeRegister |= 0x20; break;
        case PaddleModeBug: modeRegister |= 0x30; break;
    }
    BOOL paddleSwap = [preferences[PaddleSwap] boolValue];
    if (paddleSwap) modeRegister |= 0x08;
    BOOL serialEchoback = [preferences[HostSerialEchoback] boolValue];
    if (serialEchoback) modeRegister |= 0x04;
    BOOL autoSpace = [preferences[PaddleAutospace] boolValue];
    if (autoSpace) modeRegister |= 0x02;
    BOOL contestSpace = [preferences[PaddleContestSpace] boolValue];
    if (contestSpace) modeRegister |= 0x01;
    return modeRegister;
}

void decodeModeRegisterIntoDict(uint8 modeRegister, NSMutableDictionary* preferences)
{
    BOOL paddleWatchDog = (modeRegister & 0x80);
    preferences[PaddleWatchDog] = @(paddleWatchDog);
    BOOL paddleEchoback = (modeRegister & 0x40);
    preferences[HostPaddleEchoback] = @(paddleEchoback);
    PaddleModeType paddleMode;
    switch (modeRegister & 0x30) {
        case 0x00: paddleMode = PaddleModeIambicB; break;
        case 0x10: paddleMode = PaddleModeIambicA; break;
        case 0x20: paddleMode = PaddleModeUltimatic; break;
        case 0x30: paddleMode = PaddleModeBug; break;
        default: paddleMode = PaddleModeIambicB; break;
    }
    preferences[PaddleMode] = @(paddleMode);
    BOOL paddleSwap = (modeRegister & 0x08);
    preferences[PaddleSwap] = @(paddleSwap);
    BOOL serialEchoback = (modeRegister & 0x04);
    preferences[HostSerialEchoback] = @(serialEchoback);
    BOOL autoSpace = (modeRegister & 0x02);
    preferences[PaddleAutospace] = @(autoSpace);
    BOOL contestSpace = (modeRegister & 0x01);
    preferences[PaddleContestSpace] = @(contestSpace);
}

uint8 encodeWK2SidetoneRegisterFromDict(NSDictionary* preferences)
{
    uint8 sidetoneRegister = 0x00;
    SidetoneFrequencyType sidetoneFrequency = [preferences[SideToneFrequency] integerValue];
    switch (sidetoneFrequency) {
        case Sidetone4000Hz: sidetoneRegister |= 0x01; break;
        case Sidetone2000Hz: sidetoneRegister |= 0x02; break;
        case Sidetone1333Hz: sidetoneRegister |= 0x03; break;
        case Sidetone1000Hz: sidetoneRegister |= 0x04; break;
        case Sidetone800Hz: sidetoneRegister |= 0x05; break;
        case Sidetone666Hz: sidetoneRegister |= 0x06; break;
        case Sidetone571Hz: sidetoneRegister |= 0x07; break;
        case Sidetone500Hz: sidetoneRegister |= 0x08; break;
        case Sidetone444Hz: sidetoneRegister |= 0x09; break;
        case Sidetone400Hz: sidetoneRegister |= 0x0A; break;
    }
    BOOL paddleOnly = [preferences[SidetonePaddleOnly] boolValue];
    if (paddleOnly) sidetoneRegister |= 0x80;
    return sidetoneRegister;
}

void decodeWK2SidetoneRegisterIntoDict(uint8 sidetoneRegister, NSMutableDictionary* preferences)
{
    SidetoneFrequencyType freq = Sidetone4000Hz;
    switch (sidetoneRegister) {
        case 1: freq = Sidetone4000Hz; break;
        case 2: freq = Sidetone2000Hz; break;
        case 3: freq = Sidetone1333Hz; break;
        case 4: freq = Sidetone1000Hz; break;
        case 5: freq = Sidetone800Hz; break;
        case 6: freq = Sidetone666Hz; break;
        case 7: freq = Sidetone571Hz; break;
        case 8: freq = Sidetone500Hz; break;
        case 9: freq = Sidetone444Hz; break;
        case 10: freq = Sidetone400Hz; break;
        default: break; // what about 0?
    }
    preferences[SideToneFrequency] = @(freq);
    BOOL paddleOnly = sidetoneRegister & 0x80;
    preferences[SidetonePaddleOnly] = @(paddleOnly);
}

uint8 encodeWK3SidetoneRegisterFromDict(NSDictionary* preferences)
{
    uint8 sidetoneRegister = 0x00;
    NSInteger sidetoneFrequency = [preferences[SidetoneFrequency] integerValue];
    sidetoneRegister = 62500/sidetoneFrequency;
    return sidetoneRegister;
}

void decodeWK3SidetoneRegisterIntoDict(uint8 sidetoneRegister, NSMutableDictionary* preferences)
{
    NSInteger sidetoneFrequency = 62500/sidetoneRegister;
    preferences[SidetoneFrequency] = @(sidetoneFrequency);
}

uint8 encodePinConfigurationRegisterFromDict(NSDictionary* preferences)
{
    uint8 pinConfigurationRegister = 0x00;
    UltimaticPriorityType ultimaticPriority = [preferences[PaddleUltimaticPriority] integerValue];
    switch (ultimaticPriority) {
        case UltimaticPriorityNormal: break;
        case UltimaticPriorityDah: pinConfigurationRegister |= 0x40; break;
        case UltimaticPriorityDit: pinConfigurationRegister |= 0x80; break;
    }
    HangTimeType paddleHangTime = [preferences[PaddleHangTime] integerValue];
    switch (paddleHangTime) {
        case HangTimeShortest: break;
        case HangTimeShort: pinConfigurationRegister |= 0x10; break;
        case HangTimeLong: pinConfigurationRegister |= 0x20; break;
        case HangTimeLongest: pinConfigurationRegister |= 0x30; break;
    }
    BOOL key2Enable = [preferences[KeyOut2Enable] boolValue];
    if (key2Enable) pinConfigurationRegister |= 0x08;
    BOOL key1Enable = [preferences[KeyOut1Enable] boolValue];
    if (key1Enable) pinConfigurationRegister |= 0x04;
    BOOL sidetoneEnable = [preferences[SidetoneEnable] boolValue];
    if (sidetoneEnable) pinConfigurationRegister |= 0x02;
    BOOL pttEnable = [preferences[PushToTalkEnable] boolValue];
    if (pttEnable) pinConfigurationRegister |= 0x01;
    return pinConfigurationRegister;
}

void decodePinConfigurationRegisterIntoDict(uint8 pinConfigurationRegister, NSMutableDictionary* preferences)
{
    BOOL pttEnable = pinConfigurationRegister & 0x01;
    preferences[PushToTalkEnable] = @(pttEnable);
    BOOL sidetoneEnable = pinConfigurationRegister & 0x02;
    preferences[SidetoneEnable] = @(sidetoneEnable);
    BOOL key1Enable = pinConfigurationRegister & 0x04;
    preferences[KeyOut1Enable] = @(key1Enable);
    BOOL key2Enable = pinConfigurationRegister & 0x08;
    preferences[KeyOut2Enable] = @(key2Enable);
    HangTimeType paddleHangTime = HangTimeShortest;
    switch (pinConfigurationRegister & 0x30) {
        case 0x00: paddleHangTime = HangTimeShortest; break;
        case 0x10: paddleHangTime = HangTimeShort; break;
        case 0x20: paddleHangTime = HangTimeLong; break;
        case 0x30: paddleHangTime = HangTimeLongest; break;
    }
    preferences[PaddleHangTime] = @(paddleHangTime);
    UltimaticPriorityType paddleUltimaticPriority = UltimaticPriorityNormal;
    switch (pinConfigurationRegister & 0xC0) {
        case 0x40: paddleUltimaticPriority = UltimaticPriorityDah; break;
        case 0x80: paddleUltimaticPriority = UltimaticPriorityDit; break;
    }
    preferences[PaddleUltimaticPriority] = @(paddleUltimaticPriority);
}

uint8 encodeWK2Extension1RegisterFromDict(NSDictionary* preferences)
{
    uint8 extensionRegister = 0x00;
    uint8 letterSpaceAdjustment = [preferences[PaddleLetterSpace] integerValue];
    extensionRegister &= (letterSpaceAdjustment << 4);
    BOOL standaloneCut = [preferences[SerialNumberCut] boolValue];
    if (standaloneCut) extensionRegister |= 0x08;
    BOOL enablePaddleStatus = [preferences[PaddleStatusEnable] boolValue];
    if (enablePaddleStatus) extensionRegister |= 0x02;
    return extensionRegister;
}

void decodeWK2Extension1RegisterIntoDict(uint8 extensionRegister, NSMutableDictionary* preferences)
{
    NSUInteger letterSpaceAdjustment = (extensionRegister & 0xF0) >> 4;
    preferences[PaddleLetterSpace] = @(letterSpaceAdjustment);
    BOOL cutMode = extensionRegister & 0x08;
    preferences[SerialNumberCut] = @(cutMode);
    BOOL paddleStatus = extensionRegister & 0x02;
    preferences[PaddleStatusEnable] = @(paddleStatus);
}

uint8 encodeWK3Extension1RegisterFromDict(NSDictionary* preferences)
{
    uint8 extensionRegister = 0x00;
    uint8 letterSpaceAdjustment = [preferences[PaddleLetterSpace] integerValue];
    extensionRegister = (letterSpaceAdjustment &= 0x1F);
    NSUInteger userOne = [preferences[StandaloneUser] integerValue];
    if (userOne == 1) extensionRegister |= 0x80;
    BOOL messageBankOne = [preferences[MessageBank] boolValue];
    if (messageBankOne) extensionRegister |= 0x40;
    BOOL fiftyPercentTune = [preferences[KeyTuneDutyCycle] boolValue];
    if (fiftyPercentTune) extensionRegister |= 0x20;
    return extensionRegister;
}

void decodeWK3Extension1RegisterIntoDict(uint8 extensionRegister, NSMutableDictionary* preferences)
{
    NSInteger letterSpaceAdjustment = extensionRegister & 0x1F;
    preferences[PaddleLetterSpace] = @(letterSpaceAdjustment);
    BOOL userOne = extensionRegister & 0x80;
    preferences[StandaloneUser] = @(userOne);
    BOOL messageBankOne = extensionRegister & 0x40;
    preferences[MessageBank] = @(messageBankOne);
    BOOL fiftyPercentTune = extensionRegister & 0x20;
    preferences[KeyTuneDutyCycle] = @(fiftyPercentTune);
}

uint8 encodeExtension2RegisterFromDict(NSDictionary* preferences)
{
    uint8 extensionRegister = 0x00;
    BOOL enablePaddleStatus = [preferences[PaddleStatusEnable] boolValue];
    if (enablePaddleStatus) extensionRegister |= 0x80;
    BOOL fastStandaloneCommandResponse = [preferences[StandaloneFastCommand] boolValue];
    if (fastStandaloneCommandResponse) extensionRegister |= 0x40;
    BOOL standaloneNCut = [preferences[SerialNumberCut9] boolValue];
    if (standaloneNCut) extensionRegister |= 0x20;
    BOOL standaloneTCut = [preferences[SerialNumberCut0] boolValue];
    if (standaloneTCut) extensionRegister |= 0x10;
    BOOL paddleOnlySidetone = [preferences[SidetonePaddleOnly] boolValue];
    if (paddleOnlySidetone) extensionRegister |= 0x08;
    BOOL so2rMode = [preferences[PushToTalkSO2R] boolValue];
    if (so2rMode) extensionRegister |= 0x04;
    BOOL paddleMute = [preferences[PaddleMute] boolValue];
    if (paddleMute) extensionRegister |= 0x02;
    return extensionRegister;
}

void decodeExtension2RegisterIntoDict(uint8 extensionRegister, NSMutableDictionary* preferences)
{
    BOOL enablePaddleStatus = extensionRegister & 0x80;
    BOOL fastStandaloneCommandResponse = extensionRegister & 0x40;
    BOOL serial9Cut = extensionRegister & 0x20;
    BOOL serial0Cut = extensionRegister & 0x10;
    BOOL paddleOnlySidetone = extensionRegister & 0x08;
    BOOL SO2RMode = extensionRegister & 0x04;
    BOOL paddleMute = extensionRegister & 0x02;
    preferences[PaddleStatusEnable] = @(enablePaddleStatus);
    preferences[StandaloneFastCommand] = @(fastStandaloneCommandResponse);
    preferences[SerialNumberCut9] = @(serial9Cut);
    preferences[SerialNumberCut0] = @(serial0Cut);
    preferences[SidetonePaddleOnly] = @(paddleOnlySidetone);
    preferences[PushToTalkSO2R] = @(SO2RMode);
    preferences[PaddleMute] = @(paddleMute);
}





