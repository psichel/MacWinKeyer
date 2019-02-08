//
//  WK24MacAppDelegate.h
//  WK24Mac
//
//  Created by James  T. Rogers on 4/11/11.
//  Copyright 2011 Jim Rogers, W4ATK. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@import ORSSerial;
@class StandaloneSettings;
@class CCNPreferencesWindowController;

@interface MacWinKeyer : NSObject <NSApplicationDelegate, NSTextFieldDelegate, ORSSerialPortDelegate>
{
    IBOutlet NSPopUpButton* _tabSelectButton;
    IBOutlet NSTabView* _tabView;
    IBOutlet NSButton* _tuneButton;
	IBOutlet NSPopUpButton *oKeyerPortSelection;
    IBOutlet NSProgressIndicator* _busyReadWriteProgress;
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

// Bound to hidden property of gumdrop image views
@property BOOL availableStatus; // Green gumdrop : idle
@property BOOL partiallyAvailableStatus; // Yellow gumdrop : busy
@property BOOL unavailableStatus; // Red gumdrop : wait or xoff or breakin

@property ORSSerialPortManager * serialPortManager;
@property ORSSerialPort * winkeyerPort;
@property NSString* portOpenCloseButtonTitle;
@property NSString* versionString;

@property (getter = isVersion2) BOOL version2; // Implies WK2 Mode
@property (getter = isVersion3) BOOL version3; // Implies WK3 Mode
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

