//
//  Preferences.m
//  MacWinKeyer
//
//  Created by Willard Myers on 2015-03-06.
//
//

#import "Preferences.h"
#include "WinKeyerTypes.h"

NSString* winKeyerPortNamePreferenceKey = @"WinkeyerPortName";

NSString* hostSettingsKeyPath        = @"SettingsHost";
NSString* standaloneSettingsKeyPath  = @"SettingsStandalone";
NSString* standaloneSettings0KeyPath = @"SettingsStandalone0";
NSString* standaloneSettings1KeyPath = @"SettingsStandalone1";

NSString* HostPaddleEchoback        = @"HostPaddleEchoback"  ;
NSString* HostSerialEchoback        = @"HostSerialEchoback"  ;

NSString* KeyCompensation           = @"KeyCompensation"  ;
NSString* KeyFirstExtension         = @"KeyFirstExtension"  ;  // WK2
NSString* KeyOut1Enable             = @"KeyOut1Enable"  ;
NSString* KeyOut2Enable             = @"KeyOut2Enable"  ;
NSString* KeyRatio                  = @"KeyRatio"  ;
NSString* KeyTuneDutyCycle          = @"KeyTuneDutyCycle"  ;  // SA? WK3
NSString* KeyWeight                 = @"KeyWeight"  ;

NSString* Message1                  = @"Message1"  ;
NSString* Message10                 = @"Message10"  ;
NSString* Message11                 = @"Message11"  ;
NSString* Message12                 = @"Message12"  ;
NSString* Message2                  = @"Message2"  ;
NSString* Message3                  = @"Message3"  ;
NSString* Message4                  = @"Message4"  ;
NSString* Message5                  = @"Message5"  ;
NSString* Message6                  = @"Message6"  ;
NSString* Message7                  = @"Message7"  ;
NSString* Message8                  = @"Message8"  ;
NSString* Message9                  = @"Message9"  ;
NSString* MessageBank               = @"MessageBank"  ;  // SA WK3
NSString* MessageMyCall             = @"MessageMyCall"  ;

NSString* PaddleAutospace           = @"PaddleAutospace"  ;
NSString* PaddleContestSpace        = @"PaddleContestSpace"  ;
NSString* PaddleDisableDitDahMemory = @"PaddleDisableDitDahMemory"  ;
NSString* PaddleHangTime            = @"PaddleHangTime"  ;
NSString* PaddleLetterSpace         = @"PaddleLetterSpace"  ;
NSString* PaddleMode                = @"PaddleMode"  ;
NSString* PaddleMute                = @"PaddleMute"  ;  // WK3
NSString* PaddleStatusEnable        = @"PaddleStatusEnable"  ;
NSString* PaddleSwap                = @"PaddleSwap"  ;
NSString* PaddleSwitchpoint         = @"PaddleSwitchpoint"  ;
NSString* PaddleUltimaticPriority   = @"PaddleUltimaticPriority"  ;
NSString* PaddleWatchDog            = @"PaddleWatchDog"  ;

NSString* PushToTalkEnable          = @"PushToTalkEnable"  ;
NSString* PushToTalkLeadDelay       = @"PushToTalkLeadDelay"  ;
NSString* PushToTalkSO2R            = @"PushToTalkSO2R"  ;  // SA? WK3
NSString* PushToTalkTailDelay       = @"PushToTalkTailDelay"  ;

NSString* SerialNumberCut           = @"SerialNumberCut"  ;  // SA WK2
NSString* SerialNumberCut0          = @"SerialNumberCut0"  ;  // SA WK3
NSString* SerialNumberCut9          = @"SerialNumberCut9"  ;  // SA WK3

NSString* SideToneFrequency         = @"SideToneFrequency"  ;
NSString* SidetoneEnable            = @"SidetoneEnable"  ;
NSString* SidetoneFrequency         = @"SidetoneFrequency"  ;
NSString* SidetonePaddleOnly        = @"SidetonePaddleOnly"  ;

NSString* SpeedCommanded            = @"Speed"  ;
NSString* SpeedFarnsworth           = @"SpeedFarnsworth"  ;
NSString* SpeedFavorite             = @"SpeedFavorite"  ;
NSString* SpeedMinimum              = @"SpeedMinimum"  ;
NSString* SpeedMaximum              = @"SpeedMaximum"  ;
NSString* SpeedPotLock              = @"SpeedPotLock"  ;
NSString* SpeedRange                = @"SpeedRange"  ;

NSString* StandaloneFastCommand     = @"StandaloneFastCommand"  ;  // SA WK3
NSString* StandaloneUser            = @"StandaloneUser"  ;  // SA WK3

@implementation Preferences

+ (void)registerPreferenceDefaults
{
    NSMutableDictionary* defaultsDict = [NSMutableDictionary dictionary];
    
    NSMutableDictionary* settingsDict = [NSMutableDictionary dictionary];
    settingsDict[HostPaddleEchoback] = @YES;
    settingsDict[HostSerialEchoback] = @YES;
    settingsDict[KeyCompensation] = @(0);
    settingsDict[KeyFirstExtension] = @(0);
    settingsDict[KeyOut1Enable] = @YES;
    settingsDict[KeyOut2Enable] = @NO;
    settingsDict[KeyRatio] = @(50);
    settingsDict[KeyTuneDutyCycle] = @NO;
    settingsDict[KeyWeight] = @(50);
    settingsDict[Message1] = @"";
    settingsDict[Message2] = @"";
    settingsDict[Message3] = @"";
    settingsDict[Message4] = @"";
    settingsDict[Message5] = @"";
    settingsDict[Message6] = @"";
    settingsDict[MessageMyCall] = @"";
    settingsDict[PaddleAutospace] = @YES;
    settingsDict[PaddleContestSpace] = @NO;
    settingsDict[PaddleDisableDitDahMemory] = @NO;
    settingsDict[PaddleHangTime] = @(HangTimeShortest);
    settingsDict[PaddleLetterSpace] = @(0);
    settingsDict[PaddleMode] = @(PaddleModeIambicB);
    settingsDict[PaddleMute] = @NO;
    settingsDict[PaddleStatusEnable] = @NO;
    settingsDict[PaddleSwap] = @NO;
    settingsDict[PaddleSwitchpoint] = @(50);
    settingsDict[PaddleUltimaticPriority] = @(UltimaticPriorityNormal);
    settingsDict[PaddleWatchDog] = @YES;
    settingsDict[PushToTalkEnable] = @YES;
    settingsDict[PushToTalkLeadDelay] = @(0);
    settingsDict[PushToTalkSO2R] = @NO;
    settingsDict[PushToTalkTailDelay] = @(0);
    settingsDict[SerialNumberCut] = @NO;
    settingsDict[SerialNumberCut0] = @NO;
    settingsDict[SerialNumberCut9] = @NO;
    settingsDict[SideToneFrequency] = @(Sidetone500Hz); // array index
    settingsDict[SidetoneEnable] = @YES;
    settingsDict[SidetoneFrequency] = @(500); // Hz
    settingsDict[SidetonePaddleOnly] = @NO;
    settingsDict[SpeedCommanded] = @(20);
    settingsDict[SpeedFarnsworth] = @(10);
    settingsDict[SpeedFavorite] = @(20);
    settingsDict[SpeedMinimum] = @(5);
    settingsDict[SpeedMaximum] = @(40);
    settingsDict[SpeedPotLock] = @NO;
    settingsDict[SpeedRange] = @(30);
    settingsDict[StandaloneFastCommand] = @NO;
    settingsDict[StandaloneUser] = @(0);
    defaultsDict[hostSettingsKeyPath] = settingsDict;

    settingsDict = [NSMutableDictionary dictionary];
    settingsDict[HostPaddleEchoback] = @YES;
    settingsDict[HostSerialEchoback] = @YES;
    settingsDict[KeyCompensation] = @(0);
    settingsDict[KeyFirstExtension] = @(0);
    settingsDict[KeyOut1Enable] = @YES;
    settingsDict[KeyOut2Enable] = @NO;
    settingsDict[KeyRatio] = @(50);
    settingsDict[KeyTuneDutyCycle] = @NO;
    settingsDict[KeyWeight] = @(50);
    settingsDict[Message1] = @"msg1";
    settingsDict[Message2] = @"msg2";
    settingsDict[Message3] = @"msg3";
    settingsDict[Message4] = @"msg4";
    settingsDict[Message5] = @"msg5";
    settingsDict[Message6] = @"msg6";
    settingsDict[MessageMyCall] = @"";
    settingsDict[PaddleAutospace] = @YES;
    settingsDict[PaddleContestSpace] = @NO;
    settingsDict[PaddleDisableDitDahMemory] = @NO;
    settingsDict[PaddleHangTime] = @(HangTimeShortest);
    settingsDict[PaddleLetterSpace] = @(0);
    settingsDict[PaddleMode] = @(PaddleModeIambicB);
    settingsDict[PaddleMute] = @NO;
    settingsDict[PaddleStatusEnable] = @NO;
    settingsDict[PaddleSwap] = @NO;
    settingsDict[PaddleSwitchpoint] = @(50);
    settingsDict[PaddleUltimaticPriority] = @(UltimaticPriorityNormal);
    settingsDict[PaddleWatchDog] = @YES;
    settingsDict[PushToTalkEnable] = @YES;
    settingsDict[PushToTalkLeadDelay] = @(0);
    settingsDict[PushToTalkSO2R] = @NO;
    settingsDict[PushToTalkTailDelay] = @(0);
    settingsDict[SerialNumberCut] = @NO;
    settingsDict[SerialNumberCut0] = @NO;
    settingsDict[SerialNumberCut9] = @NO;
    settingsDict[SideToneFrequency] = @(Sidetone500Hz); // array index
    settingsDict[SidetoneEnable] = @YES;
    settingsDict[SidetoneFrequency] = @(500); // Hz
    settingsDict[SidetonePaddleOnly] = @NO;
    settingsDict[SpeedCommanded] = @(20);
    settingsDict[SpeedFarnsworth] = @(10);
    settingsDict[SpeedFavorite] = @(20);
    settingsDict[SpeedMinimum] = @(5);
    settingsDict[SpeedPotLock] = @NO;
    settingsDict[SpeedRange] = @(30);
    settingsDict[StandaloneFastCommand] = @NO;
    settingsDict[StandaloneUser] = @(0);
    defaultsDict[standaloneSettingsKeyPath] = settingsDict;
    
    settingsDict = [NSMutableDictionary dictionary];
    settingsDict[HostPaddleEchoback] = @YES;
    settingsDict[HostSerialEchoback] = @YES;
    settingsDict[KeyCompensation] = @(0);
    settingsDict[KeyFirstExtension] = @(0);
    settingsDict[KeyOut1Enable] = @YES;
    settingsDict[KeyOut2Enable] = @NO;
    settingsDict[KeyRatio] = @(50);
    settingsDict[KeyTuneDutyCycle] = @NO;
    settingsDict[KeyWeight] = @(50);
    settingsDict[Message1] = @"msg1";
    settingsDict[Message2] = @"msg2";
    settingsDict[Message3] = @"msg3";
    settingsDict[Message4] = @"msg4";
    settingsDict[Message5] = @"msg5";
    settingsDict[Message6] = @"msg6";
    settingsDict[MessageMyCall] = @"";
    settingsDict[PaddleAutospace] = @YES;
    settingsDict[PaddleContestSpace] = @NO;
    settingsDict[PaddleDisableDitDahMemory] = @NO;
    settingsDict[PaddleHangTime] = @(HangTimeShortest);
    settingsDict[PaddleLetterSpace] = @(0);
    settingsDict[PaddleMode] = @(PaddleModeIambicB);
    settingsDict[PaddleMute] = @NO;
    settingsDict[PaddleStatusEnable] = @NO;
    settingsDict[PaddleSwap] = @NO;
    settingsDict[PaddleSwitchpoint] = @(50);
    settingsDict[PaddleUltimaticPriority] = @(UltimaticPriorityNormal);
    settingsDict[PaddleWatchDog] = @YES;
    settingsDict[PushToTalkEnable] = @YES;
    settingsDict[PushToTalkLeadDelay] = @(0);
    settingsDict[PushToTalkSO2R] = @NO;
    settingsDict[PushToTalkTailDelay] = @(0);
    settingsDict[SerialNumberCut] = @NO;
    settingsDict[SerialNumberCut0] = @NO;
    settingsDict[SerialNumberCut9] = @NO;
    settingsDict[SideToneFrequency] = @(Sidetone500Hz); // array index
    settingsDict[SidetoneEnable] = @YES;
    settingsDict[SidetoneFrequency] = @(500); // Hz
    settingsDict[SidetonePaddleOnly] = @NO;
    settingsDict[SpeedCommanded] = @(20);
    settingsDict[SpeedFarnsworth] = @(10);
    settingsDict[SpeedFavorite] = @(20);
    settingsDict[SpeedMinimum] = @(5);
    settingsDict[SpeedPotLock] = @NO;
    settingsDict[SpeedRange] = @(30);
    settingsDict[StandaloneFastCommand] = @NO;
    settingsDict[StandaloneUser] = @(0);
    defaultsDict[standaloneSettings0KeyPath] = settingsDict;
    
    settingsDict = [NSMutableDictionary dictionary];
    settingsDict[HostPaddleEchoback] = @YES;
    settingsDict[HostSerialEchoback] = @YES;
    settingsDict[KeyCompensation] = @(0);
    settingsDict[KeyFirstExtension] = @(0);
    settingsDict[KeyOut1Enable] = @YES;
    settingsDict[KeyOut2Enable] = @NO;
    settingsDict[KeyRatio] = @(50);
    settingsDict[KeyTuneDutyCycle] = @NO;
    settingsDict[KeyWeight] = @(50);
    settingsDict[Message1] = @"msg1";
    settingsDict[Message2] = @"msg2";
    settingsDict[Message3] = @"msg3";
    settingsDict[Message4] = @"msg4";
    settingsDict[Message5] = @"msg5";
    settingsDict[Message6] = @"msg6";
    settingsDict[MessageMyCall] = @"";
    settingsDict[PaddleAutospace] = @YES;
    settingsDict[PaddleContestSpace] = @NO;
    settingsDict[PaddleDisableDitDahMemory] = @NO;
    settingsDict[PaddleHangTime] = @(HangTimeShortest);
    settingsDict[PaddleLetterSpace] = @(0);
    settingsDict[PaddleMode] = @(PaddleModeIambicB);
    settingsDict[PaddleMute] = @NO;
    settingsDict[PaddleStatusEnable] = @NO;
    settingsDict[PaddleSwap] = @NO;
    settingsDict[PaddleSwitchpoint] = @(50);
    settingsDict[PaddleUltimaticPriority] = @(UltimaticPriorityNormal);
    settingsDict[PaddleWatchDog] = @YES;
    settingsDict[PushToTalkEnable] = @YES;
    settingsDict[PushToTalkLeadDelay] = @(0);
    settingsDict[PushToTalkSO2R] = @NO;
    settingsDict[PushToTalkTailDelay] = @(0);
    settingsDict[SerialNumberCut] = @NO;
    settingsDict[SerialNumberCut0] = @NO;
    settingsDict[SerialNumberCut9] = @NO;
    settingsDict[SideToneFrequency] = @(Sidetone500Hz); // array index
    settingsDict[SidetoneEnable] = @YES;
    settingsDict[SidetoneFrequency] = @(500); // Hz
    settingsDict[SidetonePaddleOnly] = @NO;
    settingsDict[SpeedCommanded] = @(20);
    settingsDict[SpeedFarnsworth] = @(10);
    settingsDict[SpeedFavorite] = @(20);
    settingsDict[SpeedMinimum] = @(5);
    settingsDict[SpeedPotLock] = @NO;
    settingsDict[SpeedRange] = @(30);
    settingsDict[StandaloneFastCommand] = @NO;
    settingsDict[StandaloneUser] = @(0);
    defaultsDict[standaloneSettings1KeyPath] = settingsDict;
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
}

@end
