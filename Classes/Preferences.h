//
//  Preferences.h
//  MacWinKeyer
//
//  Created by Willard Myers on 2015-03-06.
//
//

#import <Foundation/Foundation.h>

extern NSString* winKeyerPortNamePreferenceKey;

extern NSString* hostSettingsKeyPath;
extern NSString* standaloneSettingsKeyPath;
extern NSString* standaloneSettings0KeyPath;
extern NSString* standaloneSettings1KeyPath;

extern NSString* HostPaddleEchoback          ;
extern NSString* HostSerialEchoback          ;
extern NSString* KeyCompensation             ;
extern NSString* KeyFirstExtension           ;  // WK2 and WK3.1, not WK3.0
extern NSString* KeyOut1Enable               ;
extern NSString* KeyOut2Enable               ;
extern NSString* KeyRatio                    ;
extern NSString* KeyTuneDutyCycle            ;  // SA? WK3
extern NSString* KeyWeight                   ;
extern NSString* Message1                    ;
extern NSString* Message10                   ;
extern NSString* Message11                   ;
extern NSString* Message12                   ;
extern NSString* Message2                    ;
extern NSString* Message3                    ;
extern NSString* Message4                    ;
extern NSString* Message5                    ;
extern NSString* Message6                    ;
extern NSString* Message7                    ;
extern NSString* Message8                    ;
extern NSString* Message9                    ;
extern NSString* MessageBank                 ;  // SA WK3
extern NSString* MessageMyCall               ;
extern NSString* PaddleAutospace             ;
extern NSString* PaddleContestSpace          ;
extern NSString* PaddleDisableDitDahMemory   ;
extern NSString* PaddleHangTime              ;
extern NSString* PaddleLetterSpace           ;
extern NSString* PaddleMode                  ;
extern NSString* PaddleMute                  ;  // SA? WK3
extern NSString* PaddleStatusEnable          ;
extern NSString* PaddleSwap                  ;
extern NSString* PaddleSwitchpoint           ;
extern NSString* PaddleUltimaticPriority     ;
extern NSString* PaddleWatchDog              ;
extern NSString* PushToTalkEnable            ;
extern NSString* PushToTalkLeadDelay         ;
extern NSString* PushToTalkSO2R              ;  // SA? WK3
extern NSString* PushToTalkTailDelay         ;
extern NSString* SerialNumberCut             ;  // SA WK2
extern NSString* SerialNumberCut0            ;  // SA WK3
extern NSString* SerialNumberCut9            ;  // SA WK3
extern NSString* SideToneFrequency           ;
extern NSString* SidetoneEnable              ;
extern NSString* SidetoneFrequency           ;
extern NSString* SidetonePaddleOnly          ;
extern NSString* SpeedCommanded              ;
extern NSString* SpeedFarnsworth             ;
extern NSString* SpeedFavorite               ;
extern NSString* SpeedMinimum                ;
extern NSString* SpeedMaximum                ;  // Host mode
extern NSString* SpeedPotLock                ;
extern NSString* SpeedRange                  ;
extern NSString* StandaloneFastCommand       ;  // SA WK3
extern NSString* StandaloneUser              ;  // SA WK3

@interface Preferences : NSObject

+ (void)registerPreferenceDefaults;

@end
