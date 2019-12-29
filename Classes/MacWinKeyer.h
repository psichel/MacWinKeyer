//
//  WK24MacAppDelegate.h
//  WK24Mac
//
//  Created by James  T. Rogers on 4/11/11.
//  Copyright 2011 Jim Rogers, W4ATK. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WinKeyerTypes.h"
@import ORSSerial;
@class StandaloneSettings;
@class CCNPreferencesWindowController;

@interface MacWinKeyer : NSObject <NSApplicationDelegate, NSTextFieldDelegate, ORSSerialPortDelegate>
{
    IBOutlet NSProgressIndicator* _busyReadWriteProgressWK2;
    IBOutlet NSProgressIndicator* _busyReadWriteProgressWK3;
    IBOutlet StandaloneSettings* _standaloneSettings;
    
	NSUInteger _keyboardBufferCharacterIndex;
    BOOL _suppressEchoTestCharacterDisplay;
}

@property BOOL waitState;
@property BOOL busyState;
@property BOOL paddleBreakinState;
@property BOOL bufferNearlyFullState;

@property NSString* keyboardBufferString;
@property NSString* paddleEchoString;

@property (getter = isHostMode) BOOL hostMode;

@property NSString* statusString;
@property NSImage* statusGumdropImage;

@property ORSSerialPortManager * serialPortManager;
@property ORSSerialPort * winkeyerPort;
@property NSString* portOpenCloseButtonTitle;
@property NSString* versionString;

@property WinKeyerType type;
@property (getter = isVersion2) BOOL version2; // Implies WK2 Mode
@property (getter = isVersion3) BOOL version3; // Implies WK3 Mode
@property (getter = isVersion31) BOOL version31; // Temporary to prohibit writting EEPROM with wrong layout
@property (getter = hasStandalone) BOOL standalone; // WKmini -- no standalone mode

@property NSUInteger currentSpeed;

@property BOOL terminating;

- (IBAction)openOrCloseWinKeyer:(id)sender;
- (IBAction)sendMessage1:(id)sender;
- (IBAction)sendMessage2:(id)sender;
- (IBAction)sendMessage3:(id)sender;
- (IBAction)sendMessage4:(id)sender;
- (IBAction)sendMessage5:(id)sender;
- (IBAction)sendMessage6:(id)sender;
- (IBAction)clearKeyboardBuffer:(id)sender;
- (IBAction)tune:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)togglePotLock:(id)sender;
- (IBAction)changeSpeed:(id)sender;
- (IBAction)changeFavoriteSpeed:(id)sender;
- (IBAction)changeRatio:(id)sender;
- (IBAction)changeWeight:(id)sender;
- (IBAction)changeKeyingCompensation:(id)sender;
- (IBAction)changePTT:(id)sender;
- (IBAction)changeFirstExtension:(id)sender;
- (IBAction)changeFarnsworthSpeed:(id)sender;
- (IBAction)changePaddleSwitchpoint:(id)sender;
- (IBAction)changePinConfiguration:(id)sender;
- (IBAction)changeModeRegister:(id)sender;
- (IBAction)changeSidetone:(id)sender;
- (IBAction)changeSpeedPot:(id)sender;
- (IBAction)changeExtensionRegister1:(id)sender;
- (IBAction)changeExtensionRegister2:(id)sender;

- (IBAction)playStandaloneMessage:(id)sender;
- (IBAction)readEeprom:(id)sender;
- (IBAction)writeEeprom:(id)sender;

- (void)loadDefaults;
- (void)insertInput:(NSString*)string;

@end

