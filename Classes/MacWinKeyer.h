//
//  WK24MacAppDelegate.h
//  WK24Mac
//
//  Created by James  T. Rogers, W4ATK on 4/11/11.
//

#import <Cocoa/Cocoa.h>
#import "WinKeyerTypes.h"
@import ORSSerial;
@class StandaloneSettings;
@class CCNPreferencesWindowController;

@interface MacWinKeyer : NSObject <NSApplicationDelegate, NSTextViewDelegate, ORSSerialPortDelegate>
{
    IBOutlet NSProgressIndicator* _busyReadWriteProgressWK2;
    IBOutlet NSProgressIndicator* _busyReadWriteProgressWK3;
    IBOutlet StandaloneSettings* _standaloneSettings;
    IBOutlet NSTextView* _keyboardBufferTextView;
    IBOutlet NSWindow* _myWindow;
    
	NSUInteger _keyboardBufferCharacterIndex;   // Position of next character to send to WinKeyer.
    NSUInteger _keyboardBufferSentIndex;        // Position of next character not yet output as Morse code.
    // The difference between these two positions are the "characters in flight".
    // That is, characters sent to the keyer but not yet output as Morse code.
}

@property BOOL waitState;
@property BOOL busyState;
@property BOOL paddleBreakinState;
@property BOOL bufferNearlyFullState;

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
- (void)textDidChange:(NSNotification *)notification;
- (NSUInteger)updateKeyboardSentIndex:(NSString*)sentCharacter;
- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error;

@end

